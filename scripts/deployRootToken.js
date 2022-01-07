const hre = require('hardhat');

const mainnetMintableERC1155PredicateProxy = '0x2d641867411650cd05dB93B59964536b1ED5b1B7';
const goerliMintableERC1155PredicateProxy = '0x72d6066F486bd0052eefB9114B66ae40e0A6031a';

async function main() {
  const RootToken = await hre.ethers.getContractFactory('DummyMintableERC1155');
  const rootToken = await RootToken.deploy(
    'https://ipfs.io/ipfs/QmPs2SxSoYgrpt8WGgkM8R8vojsXA9e6Gp5JWJ81bcMKw4/',
    goerliMintableERC1155PredicateProxy,
  );

  await rootToken.deployed();

  console.log('RootToken deployed to:', rootToken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
