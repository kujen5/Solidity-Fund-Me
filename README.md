# Solidity Fund Me

`Solidity Fund Me` is a project that aims to familiarize you with Solidity and Smart Contract concepts. It consists of basic features allowing the user fund a contract and for the contract owner to withdraw all the funds withing that contract. It also contains various other methods allowing interactions with the priceFeed that's being used to retrieve the real-time token conversion rate.
## Getting Started

### Requirements

- [foundry](https://getfoundry.sh/)
    - You will know your installation is successful if you can run `forge --version`

### Setup

Clone this repository:
```
git clone https://github.com/kujen5/Solidity-Fund-Me
```

Create and setup an account on https://etherscan.io/ to claim an Etherscan API key.

Create and setup and account on https://dashboard.alchemy.com/ to be able to create an application using Ethereum Sepolia and finally claim your Sepolia RPC Url.

Create an account on https://metamask.io/ and setup a wallet to be able to claim your private key. You can also add metamask as a plugin in your browser.

Go to your Metamask wallet => Show test networks => select Sepolia. We'll be needing it.

Create an `.env` file where you put your private keys and API keys like this:
```
DEFAULT_ANVIL_PRIVATE_KEY=<value>
ETHEREUM_SEPOLIA_PRIVATE_KEY=<value>
ETHERSCAN_API_KEY=<value>
ETHEREUM_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/<value>

ZKSYNC_SEPOLIA_API_KEY=<value>
ZKSYNC_SEPOLIA_PRIVATE_KEY=<value>
#ZKSYNC_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/<value>
DEFAULT_ZKSYNC_LOCAL_KEY=<value>

SENDER_ADDRESS=<value>
```

Finally, source your `.env` file: `source .env` or you could just use your Makefile command which will source it automatically.


## Usage
1. Setup your `anvil` chain by running this command in your terminal:
```bash
anvil
```

You will find an RPC URL (`http://127.0.0.1:8545` by default) and multiple accounts associated with their corresponding private keys. Choose a private key to work with. (The first account private key is hardcoded in the `HelperConfig.s.sol` file).


2. Compile your code:
Run:

```bash
forge compile
```

Or:

```bash
make compile
```

3. Deploying the contract to the Anvil local chain:

Run:

```bash
forge script script/DeployFundMe.s.sol --rpc-url http://127.0.0.1:8545  --broadcast --private-key $DEFAULT_ANVIL_PRIVATE_KEY
```

Or: 
```bash
make deploy
```

4. Deploying the contract to the Ethereum Sepolia testnet:

Run:
```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $ETHEREUM_SEPOLIA_PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

Or:
```bash
make deploy ARGS="--network ethsepolia"
```
You can now interact with your contract on chain by grabbing your contract's address and putting it in https://sepolia.etherscan.io/

### Interacting with the Smart Contract

#### Retrieving the Contract Owner

Run: (The following private key belong to the local Anvil chain, no worries in expsing it.)
```bash
$ cast call 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "getOwner()" --private-key $DEFAULT_ANVIL_PRIVATE_KEY 
0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

#### Retrieving the used Price Feed for price conversion

Run:

```bash
$ cast call 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "getPriceFeed()" --private-key
 $DEFAULT_ANVIL_PRIVATE_KEY 
0x000000000000000000000000b7f8bc63bbcad18155201308c8f3540b07f84f5e
```

#### Funding the Contract


Run:

```bash
kujen@kujen:~/Blockchain/personal_projects/Solidity-Fund-Me$ cast send 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "fund()" --value 0.1ether --private-key $DEFAULT_ANVIL_PRIVATE_KEY 

blockHash               0x00e3c9171df49a9d93d7992e2d8bc08369203fe6fae18b97fc22ca5aff3d9a30
blockNumber             12
contractAddress         
cumulativeGasUsed       106190
effectiveGasPrice       244954860
from                    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
gasUsed                 106190
logs                    [{"address":"0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0","topics":["0x2377f896bb25e2218cb6a3b9e48cad43b440fa9eec2b04fa3e995a994fd366d7"],"data":"0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000000000000000000000000000016345785d8a0000","blockHash":"0x00e3c9171df49a9d93d7992e2d8bc08369203fe6fae18b97fc22ca5aff3d9a30","blockNumber":"0xc","blockTimestamp":"0x680526b5","transactionHash":"0x4b7004339bf0bc328bf4f786229ec81fbc8c034becc887488c035430c8ff048e","transactionIndex":"0x0","logIndex":"0x0","removed":false}]
logsBloom               0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000002000000000000000000000000000000000000000000000000002000000000000000000000000400000000000
root                    
status                  1 (success)
transactionHash         0x4b7004339bf0bc328bf4f786229ec81fbc8c034becc887488c035430c8ff048e
transactionIndex        0
type                    2
blobGasPrice            1
blobGasUsed             
authorizationList       
to                      0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0
```

### Retrieving the Contract Balance (upon funding)

```bash
$ cast call 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "getContractBalance()" --private-key $DEFAULT_ANVIL_PRIVATE_KEY 
0x000000000000000000000000000000000000000000000000016345785d8a0000
```

And we can verify this value using cast:
```bash
$ cast --to-base 0x000000000000000000000000000000000000000000000000016345785d8a0000 decimal
100000000000000000
```

Which translates directly to 0.1ether.

#### Retrieving the funder address by their index

```bash
$ cast call 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "getFunderByIndex(uint256)" 0 
--private-key $DEFAULT_ANVIL_PRIVATE_KEY 
0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

Which is our current funder's address.

#### Withdrawing all the funds in the contract

```bash
$ cast send 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "withdraw()"  --private-key $D
EFAULT_ANVIL_PRIVATE_KEY 

blockHash               0x3e2ff496336f8c33a028f0abd833bad78d5fe208da5db285bfbde04a61e2c6e7
blockNumber             13
contractAddress         
cumulativeGasUsed       35261
effectiveGasPrice       214552268
from                    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
gasUsed                 35261
logs                    []
logsBloom               0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
root                    
status                  1 (success)
transactionHash         0x755f9fd90670ffc09dbfb8e24e6367f1e32468f226eade1edda95dcec2bfff2c
transactionIndex        0
type                    2
blobGasPrice            1
blobGasUsed             
authorizationList       
to                      0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0
```

We can now check the contract balance and it should be 0 since we withdrew all the funds:

```bash
$ cast call 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 "getContractBalance()" --private-key $DEFAULT_ANVIL_PRIVATE_KEY 
0x0000000000000000000000000000000000000000000000000000000000000000
```


## Test Coverage

The current test coverage is at ~70% with unit and integration tests, it's still not perfect but I will keep working on it in the future:

```
╭--------------------------------+-----------------+-----------------+---------------+----------------╮
| File                           | % Lines         | % Statements    | % Branches    | % Funcs        |
+=====================================================================================================+
| script/DeployFundMe.s.sol      | 87.50% (14/16)  | 88.89% (16/18)  | 100.00% (0/0) | 50.00% (1/2)   |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| script/HelperConfig.s.sol      | 84.00% (21/25)  | 77.27% (17/22)  | 20.00% (1/5)  | 100.00% (5/5)  |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| script/Interactions.s.sol      | 31.25% (5/16)   | 28.57% (4/14)   | 100.00% (0/0) | 25.00% (1/4)   |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| src/FundMe.sol                 | 69.44% (25/36)  | 71.88% (23/32)  | 50.00% (3/6)  | 63.64% (7/11)  |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| src/PriceConverter.sol         | 100.00% (7/7)   | 100.00% (8/8)   | 100.00% (0/0) | 100.00% (2/2)  |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| test/mock/MockV3Aggregator.sol | 52.17% (12/23)  | 52.94% (9/17)   | 100.00% (0/0) | 50.00% (3/6)   |
|--------------------------------+-----------------+-----------------+---------------+----------------|
| Total                          | 68.29% (84/123) | 69.37% (77/111) | 36.36% (4/11) | 63.33% (19/30) |
╰--------------------------------+-----------------+-----------------+---------------+----------------╯
```



## TODO

- [ ] Implement more tests (Fuzz Tests / Unit Tests / Mutations Tests) to better test our code.
- [ ] Implement Network Configurations for Arbitrum Sepolia, and other networks.
- [ ] Add more features.

## Thank you!

This project has been made with love as a learning experience. The best is yet to come.
Please give the project a star if you like it!