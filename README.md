# Optino Governance DAO Smart Contracts

Status: **Work In Progress**

The Optino Governance (OptinoGov) smart contract is the Decentralised Autonomous Organisation (DAO) that operates the Optino Vending Machine.

Optino Governance token (OGToken) holders lock their OGTokens into the OptinoGov smart contract to submit and vote on proposals. If successful, the proposal will be executed, e.g., the minting of new OGTokens, the burning of staked tokens, and setting of fee rates.

When OGTOkens are locked into the OptinoGov smart contract, the equivalent number of Optino Governance Dividend token (OGDToken) are minted. These tokens will accrue fees generated by the Optino Vending Machine.

Following are the main smart contracts:

* [contracts/OptinoGov.sol](contracts/OptinoGov.sol) - [flattened](flattened/OptinoGov_flattened.sol)
* [contracts/OGToken.sol](contracts/OGToken.sol) - [flattened](flattened/OGToken_flattened.sol)
* [contracts/OGDToken.sol](contracts/OGDToken.sol) - [flattened](flattened/OGDToken_flattened.sol)

See also:

* https://wiki.optino.io

<br />

<hr />

### Remix

To test out these smart contracts in [Remix](http://remix.ethereum.org/), copy the contents of the files above into the same file names within Remix. Comment out the local `import ".\{file.sol}"` and uncomment the GitHub `import "https://github.com/ogDAO/Governance/blob/master/contracts/{file}.sol";`.

<br />

<hr />

### Testing

#### Clone Repository
Check out this repository into your projects subfolder:

```
git clone https://github.com/ogDAO/Governance.git
cd Governance
```

<br />

#### Install And Run Go Ethereum

Install [Go-Ethereum](https://github.com/ethereum/go-ethereum) (also known as `geth`) on your local computer to run a development blockchain node for testing. Or install and use [Ganache](https://www.trufflesuite.com/ganache) instead.

If you have installed `geth`, run:

```
./00_runGeth.sh
./01_unlockAndFundAccounts.sh
```

You may need to `chmod 700 00_runGeth.sh 01_unlockAndFundAccounts.sh` before being able to execute it.

<br />

#### Install Truffle


If not already installed, you will need [NPM](https://www.npmjs.com/). [NVM](https://github.com/nvm-sh/nvm) may take away some of your NPM versioning pain.

You will need to install [Truffle](https://github.com/trufflesuite/truffle):

```
npm install -g truffle
```

<br />

#### Install Truffle Flattener And Flatten Solidity Files

You may want to to install [Truffle Flattener](https://github.com/nomiclabs/truffle-flattener) using the command:

```
npm install -g truffle-flattener
./10_flattenSolidityFiles.sh
```

The flattened files can be found in the [./flattened/](./flattened/) subdirectory.

<br />

#### Install Other Modules

You will need the following modules installed:

```
npm install --save web3@1.2.1
npm install --save ethers
npm install --save eth-sig-util
npm install --save bignumber.js

```

<br />

#### Compile

```
truffle compile
```

<br />

#### Run Tests

```
truffle test test/TestOptinoGov.test.js
```

Sample output:

```
Iota:Governance bok$ truffle test test/TestOptinoGov.test.js --show-events
Using network 'development'.


Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.

TestToken.test.js: describe(TestToken behavior tests)


  Contract: Test OptinoGov
--- Setup completed ---
RESULT:  # Account                                             EtherBalanceChange                             OG                            OGD @ 26402 -> 26418
RESULT:                                                                                                      FEE
RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
RESULT: 0 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E         0.000000000000000000       10000.000000000000000000           0.000000000000000000 Owner:0xa00A
RESULT:                                                                                     0.000000000000000000
RESULT: 1 0xa11AAE29840fBb5c86E6fd4cF809EBA183AEf433         0.000000000000000000       10000.000000000000000000           0.000000000000000000 User1:0xa11A
RESULT:                                                                                     0.000000000000000000
RESULT: 2 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976         0.000000000000000000       10000.000000000000000000           0.000000000000000000 User2:0xa22A
RESULT:                                                                                     0.000000000000000000
RESULT: 3 0xa33a6c312D9aD0E0F2E95541BeED0Cc081621fd0         0.000000000000000000       10000.000000000000000000           0.000000000000000000 User3:0xa33a
RESULT:                                                                                     0.000000000000000000
RESULT: 4 0xDbbDc53908A2b376a288D4196F1Aa6628EF0b89E         0.000000000000000000           0.000000000000000000           0.000000000000000000 OGToken:0xDbbD
RESULT:                                                                                     0.000000000000000000
RESULT: 5 0xC2C696936EC96ea90a4cCE6C1287Ac31C4Bc0d76         0.000000000000000000           0.000000000000000000           0.000000000000000000 OGDToken:0xC2C6
RESULT:                                                                                     0.000000000000000000
RESULT: 6 0x37a830AB28aDC206D509Dc889c90068CA064E50d         0.000000000000000000           0.000000000000000000           0.000000000000000000 FeeToken:0x37a8
RESULT:                                                                                     0.000000000000000000
RESULT: 7 0x974ca6bb0aDc353e98897Dc214bB44C94834aB0A         0.000000000000000000           0.000000000000000000           0.000000000000000000 OptinoGov:0x974c
RESULT:                                                                                     0.000000000000000000
RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
RESULT:                                                                                 40000.000000000000000000           0.000000000000000000 Total Token Balances
RESULT:                                                                                     0.000000000000000000
RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
RESULT:
RESULT: Token 0 OGToken:0xDbbD @ 0xDbbDc53908A2b376a288D4196F1Aa6628EF0b89E
RESULT: - symbol               : OG
RESULT: - name                 : Optino Governance
RESULT: - decimals             : 18
RESULT: - totalSupply          : 40000
RESULT: - owner                : OptinoGov:0x974c
RESULT: Token 1 OGDToken:0xC2C6 @ 0xC2C696936EC96ea90a4cCE6C1287Ac31C4Bc0d76
RESULT: - symbol               : OGD
RESULT: - name                 : Optino Governance Dividend
RESULT: - decimals             : 18
RESULT: - totalSupply          : 0
RESULT: - owner                : OptinoGov:0x974c
RESULT: - dividendTokenLength  : 2
RESULT: - dividendTokens       : 0 0x0000000000000000000000000000000000000000
RESULT: - dividendTokens       : 1 FeeToken:0x37a8
RESULT: Token 2 FeeToken:0x37a8 @ 0x37a830AB28aDC206D509Dc889c90068CA064E50d
RESULT: - symbol               : FEE
RESULT: - name                 : Fee
RESULT: - decimals             : 18
RESULT: - totalSupply          : 0
RESULT: - owner                : Owner:0xa00A
RESULT: OptinoGov OptinoGov:0x974c @ 0x974ca6bb0aDc353e98897Dc214bB44C94834aB0A
RESULT: - ogToken              : OGToken:0xDbbD
RESULT: - ogdToken             : OGDToken:0xC2C6
RESULT: - maxLockTerm          : 1000 seconds = 0.01157407407407407407 days
RESULT: - rewardsPerSecond     : 150000000000000000 = 12960 per day
RESULT: - proposalCost         : 100000000000000000000 = 100
RESULT: - proposalThreshold    : 1000000000000000 = 0.1%
RESULT: - quorum               : 200000000000000000 = 20%
RESULT: - quorumDecayPerSecond : 12683916793 = 39.9999999984048% per year
RESULT: - votingDuration       : 10 seconds = 0.00011574074074074074 days
RESULT: - executeDelay         : 10 seconds = 0.00011574074074074074 days
RESULT: - rewardPool           : 0 = 0
RESULT: - totalVotes           : 0 = 0
RESULT: - proposalCount        : 0
RESULT: - stakeInfoLength      : 0
    ✓ Test getBlockNumber 2 (263ms)

    Events emitted during test:
    ---------------------------

    OGDToken.OwnershipTransferred(
      _from: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      _to: <indexed> 0x523e77749070D790eE6a32777F433389dccF4b1F (type: address)
    )

    OGToken.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      tokens: 10000000000000000000000 (type: uint256)
    )

    OGDToken.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      tokens: 0 (type: uint256)
    )

    ERC20.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      tokens: 0 (type: uint256)
    )

    OGToken.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa11AAE29840fBb5c86E6fd4cF809EBA183AEf433 (type: address),
      tokens: 10000000000000000000000 (type: uint256)
    )

    OGToken.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa33a6c312D9aD0E0F2E95541BeED0Cc081621fd0 (type: address),
      tokens: 10000000000000000000000 (type: uint256)
    )

    OGToken.Transfer(
      from: <indexed> 0x0000000000000000000000000000000000000000 (type: address),
      to: <indexed> 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976 (type: address),
      tokens: 10000000000000000000000 (type: uint256)
    )

    OGDToken.DividendTokensAdded(
      dividendToken: 0x0000000000000000000000000000000000000000 (type: address)
    )

    OGDToken.DividendTokensAdded(
      dividendToken: 0x37a830AB28aDC206D509Dc889c90068CA064E50d (type: address)
    )

    OGToken.OwnershipTransferred(
      _from: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      _to: <indexed> 0x974ca6bb0aDc353e98897Dc214bB44C94834aB0A (type: address)
    )

    OGDToken.OwnershipTransferred(
      _from: <indexed> 0xa00Af22D07c87d96EeeB0Ed583f8F6AC7812827E (type: address),
      _to: <indexed> 0x974ca6bb0aDc353e98897Dc214bB44C94834aB0A (type: address)
    )


    ---------------------------


  1 passing (17s)
```

<br />

#### Debug

```
truffle debug {txHash}
```

<br />

#### Migrate

```
truffle migrate [--reset]
```

<br />

<br />

Enjoy!

(c) The Optino Project 2020. GPLv2
