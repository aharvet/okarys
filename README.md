# Okarys

Okarys is an EIP 1155 collectibles collection, which restricts the mint of each id to 149 pieces for compliance matter.

It is compatible with EIP 2981 for on chain royalties ([see EIP 2981](https://eips.ethereum.org/EIPS/eip-2981)) and with the polygon bridge.

It is a so called mintable contract. Meaning that the original collectibles are minted on the Polygon L2, and can then be bridged to mainnet. ([see Polygon docs](https://docs.polygon.technology/docs/develop/ethereum-polygon/mintable-assets))

## Constructor

`string _name` : name of the collection

`string _uri` : uri of the collection

`address royaltyReceiver` : address that will receive the royalties

`uint256 royaltyPercentage` : percentage of the price to be royalty

`address childChainManager` : address of Polygon's child manager contract (docs above)

## Instalation

Run

```
npm i
```

Copy `.env.example`, rename it to `.env` and fill the fields.

## Test

```
npx hardhat test
```

## Deployment

Main Polygon contract:

```
npx hardhat run scripts/deployOkarys.js --network <polygon | mumbai>
```

Mainnet child token for bridge:

```
npx hardhat run scripts/deployRootToken.js --network <mainnet | goerli>
```

# Etherscan/Polygonscan verification

Copy the deployment address and paste it in to replace DEPLOYED_CONTRACT_ADDRESS in this command:

```
npx hardhat verify --network <TARGETED_NETWORK> <DEPLOYED_CONTRACT_ADDRESS> "constructor argument 1" "constructor argument 2" "constructor argument 3" "constructor argument 4" "constructor argument 5"
```

## Flatten contract

```
npx hardhat flatten > flatten/Okarys-flat.sol
```
