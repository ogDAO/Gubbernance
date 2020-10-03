pragma solidity ^0.7.0;
// pragma experimental ABIEncoderV2;

// import "https://github.com/ogDAO/Governance/blob/master/contracts/Permissioned.sol";
// import "https://github.com/ogDAO/Governance/blob/master/contracts/OGDTokenInterface.sol";

import "./Permissioned.sol";
import "./OGDTokenInterface.sol";


// ----------------------------------------------------------------------------
// DividendTokens - [token] => [enabled]
// ----------------------------------------------------------------------------
library DividendTokens {
    struct DividendToken {
        uint timestamp;
        uint index;
        address token;
        bool enabled;
    }
    struct Data {
        bool initialised;
        mapping(address => DividendToken) entries;
        address[] index;
    }

    event DividendTokenAdded(address indexed token, bool enabled);
    event DividendTokenRemoved(address indexed token);
    event DividendTokenUpdated(address indexed token, bool enabled);

    function init(Data storage self) internal {
        require(!self.initialised);
        self.initialised = true;
    }
    function hasKey(Data storage self, address token) internal view returns (bool) {
        return self.entries[token].timestamp > 0;
    }
    function add(Data storage self, address token, bool enabled) internal {
        require(self.entries[token].timestamp == 0, "DividendToken.add: Cannot add duplicate");
        self.index.push(token);
        self.entries[token] = DividendToken(block.timestamp, self.index.length - 1, token, enabled);
        emit DividendTokenAdded(token, enabled);
    }
    function remove(Data storage self, address token) internal {
        require(self.entries[token].timestamp > 0, "DividendToken.update: Address not registered");
        uint removeIndex = self.entries[token].index;
        emit DividendTokenRemoved(token);
        uint lastIndex = self.index.length - 1;
        address lastIndexKey = self.index[lastIndex];
        self.index[removeIndex] = lastIndexKey;
        self.entries[lastIndexKey].index = removeIndex;
        delete self.entries[token];
        if (self.index.length > 0) {
            self.index.pop();
        }
    }
    function update(Data storage self, address token, bool enabled) internal {
        DividendToken storage _value = self.entries[token];
        require(_value.timestamp > 0, "DividendToken.update: Address not registered");
        _value.timestamp = block.timestamp;
        _value.enabled = enabled;
        emit DividendTokenUpdated(token, enabled);
    }
    function length(Data storage self) internal view returns (uint) {
        return self.index.length;
    }
}


/// @notice Optino Governance Dividend Token = ERC20 + mint + burn + dividend payments. (c) The Optino Project 2020
// SPDX-License-Identifier: GPLv2
contract OGDToken is OGDTokenInterface, Permissioned {
    using SafeMath for uint;
    using DividendTokens for DividendTokens.Data;
    using DividendTokens for DividendTokens.DividendToken;

    struct Account {
      uint balance;
      mapping(address => uint) lastDividendPoints;
      mapping(address => uint) owing;
    }

    string _symbol;
    string  _name;
    uint8 _decimals;
    uint _totalSupply;
    mapping(address => Account) accounts;
    mapping(address => mapping(address => uint)) allowed;

    DividendTokens.Data private dividendTokens;

    // uint public constant pointMultiplier = 10e18;
    uint public constant pointMultiplier = 10e27;
    mapping(address => uint) public totalDividendPoints;
    mapping(address => uint) public unclaimedDividends;

    event LogInfo(string topic, uint number, bytes32 data, string note, address addr);
    event UpdateAccountInfo(address dividendToken, address account, uint owing, uint totalOwing, uint lastDividendPoints, uint totalDividendPoints, uint unclaimedDividends);
    event DividendDeposited(address indexed token, uint tokens);
    event DividendWithdrawn(address indexed account, address indexed token, uint tokens);

    // CHECK: Duplicated from the library for ABI generation
    // event DividendTokenAdded(address indexed token, bool enabled);
    // event DividendTokenRemoved(address indexed token);
    // event DividendTokenUpdated(address indexed token, bool enabled);

    constructor(string memory symbol, string memory name, uint8 decimals, address tokenOwner, uint initialSupply) {
        initPermissioned(msg.sender);
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        accounts[tokenOwner].balance = initialSupply;
        _totalSupply = initialSupply;
        emit Transfer(address(0), tokenOwner, _totalSupply);
    }
    function symbol() override external view returns (string memory) {
        return _symbol;
    }
    function name() override external view returns (string memory) {
        return _name;
    }
    function decimals() override external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() override external view returns (uint) {
        return _totalSupply.sub(accounts[address(0)].balance);
    }
    function balanceOf(address tokenOwner) override external view returns (uint balance) {
        return accounts[tokenOwner].balance;
    }
    function transfer(address to, uint tokens) override external returns (bool success) {
        updateAccount(msg.sender);
        updateAccount(to);
        accounts[msg.sender].balance = accounts[msg.sender].balance.sub(tokens);
        accounts[to].balance = accounts[to].balance.add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) override external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) override external returns (bool success) {
        updateAccount(msg.sender);
        updateAccount(to);
        accounts[from].balance = accounts[from].balance.sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        accounts[to].balance = accounts[to].balance.add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) override external view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function addDividendToken(address _dividendToken) external onlyOwner {
        if (!dividendTokens.initialised) {
            dividendTokens.init();
        }
        dividendTokens.add(_dividendToken, true);
    }
    function updateDividendToken(address token, bool enabled) public onlyOwner {
        require(dividendTokens.initialised);
        dividendTokens.update(token, enabled);
    }
    function removeDividendToken(address token) public onlyOwner {
        require(dividendTokens.initialised);
        dividendTokens.remove(token);
    }
    function getDividendTokenByIndex(uint i) public view returns (address, bool) {
        require(i < dividendTokens.length(), "Invalid dividend token index");
        DividendTokens.DividendToken memory dividendToken = dividendTokens.entries[dividendTokens.index[i]];
        return (dividendToken.token, dividendToken.enabled);
    }
    function dividendTokensLength() public view returns (uint) {
        return dividendTokens.length();
    }

    function newDividendsOwing(address dividendToken, address account) internal view returns (uint) {
        uint newDividendPoints = totalDividendPoints[dividendToken].sub(accounts[account].lastDividendPoints[dividendToken]);
        return accounts[account].balance.mul(newDividendPoints).div(pointMultiplier);
    }
    function dividendsOwing(address account) public view returns (address[] memory tokenList, uint[] memory owingList) {
        tokenList = new address[](dividendTokens.index.length);
        owingList = new uint[](dividendTokens.index.length);
        for (uint i = 0; i < dividendTokens.index.length; i++) {
            DividendTokens.DividendToken memory dividendToken = dividendTokens.entries[dividendTokens.index[i]];
            uint owing = dividendToken.enabled ? accounts[account].owing[dividendToken.token] + newDividendsOwing(dividendToken.token, account) : 0;
            tokenList[i] = dividendToken.token;
            owingList[i] = owing;
        }
    }
    function updateAccount(address account) internal {
        for (uint i = 0; i < dividendTokens.index.length; i++) {
            DividendTokens.DividendToken memory dividendToken = dividendTokens.entries[dividendTokens.index[i]];
            if (dividendToken.enabled) {
                uint owing = newDividendsOwing(dividendToken.token, account);
                if (owing > 0) {
                    unclaimedDividends[dividendToken.token] = unclaimedDividends[dividendToken.token].sub(owing);
                    accounts[account].lastDividendPoints[dividendToken.token] = totalDividendPoints[dividendToken.token];
                    accounts[account].owing[dividendToken.token] = accounts[account].owing[dividendToken.token].add(owing);
                }
            }
        }
    }

    function depositDividend(address token, uint tokens) public payable {
        DividendTokens.DividendToken memory _dividendToken = dividendTokens.entries[token];
        require(_dividendToken.enabled, "Dividend token is not enabled");
        totalDividendPoints[token] = totalDividendPoints[token].add((tokens * pointMultiplier / _totalSupply));
        unclaimedDividends[token] = unclaimedDividends[token].add(tokens);
        if (token == address(0)) {
            require(msg.value >= tokens, "Insufficient ETH sent");
            uint refund = msg.value.sub(tokens);
            if (refund > 0) {
                require(msg.sender.send(refund), "ETH refund failure");
            }
        } else {
            ERC20(token).transferFrom(msg.sender, address(this), tokens);
        }
        emit DividendDeposited(token, tokens);
    }
    receive () external payable {
        depositDividend(address(0), msg.value);
    }

    function withdrawDividendsFor(address account) internal {
        updateAccount(account);
        for (uint i = 0; i < dividendTokens.index.length; i++) {
            DividendTokens.DividendToken memory dividendToken = dividendTokens.entries[dividendTokens.index[i]];
            if (dividendToken.enabled) {
                uint tokens = accounts[account].owing[dividendToken.token];
                if (tokens > 0) {
                    accounts[account].owing[dividendToken.token] = 0;
                    if (dividendToken.token == address(0)) {
                        payable(account).transfer(tokens);
                    } else {
                        ERC20(dividendToken.token).transfer(account, tokens);
                    }
                }
                emit DividendWithdrawn(account, dividendToken.token, tokens);
            }
        }
    }
    function withdrawDividends() public {
        withdrawDividendsFor(msg.sender);
    }

    function mint(address tokenOwner, uint tokens) override external permitted(ROLE_MINTER, tokens) returns (bool success) {
        processed(ROLE_MINTER, tokens);
        accounts[tokenOwner].balance = accounts[tokenOwner].balance.add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), tokenOwner, tokens);
        updateAccount(tokenOwner);
        return true;
    }
    function burn(uint tokens) override external returns (bool success) {
        updateAccount(msg.sender);
        withdrawDividendsFor(msg.sender);
        accounts[msg.sender].balance = accounts[msg.sender].balance.sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function recoverTokens(address token, uint tokens) public onlyOwner {
        DividendTokens.DividendToken memory dividendToken = dividendTokens.entries[token];
        require(dividendToken.timestamp == 0, "Cannot recover tokens in dividend token list");
        if (token == address(0)) {
            payable(owner).transfer((tokens == 0 ? address(this).balance : tokens));
        } else {
            ERC20(token).transfer(owner, tokens == 0 ? ERC20(token).balanceOf(address(this)) : tokens);
        }
    }
}
