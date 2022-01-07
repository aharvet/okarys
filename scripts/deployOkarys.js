const hre = require('hardhat');

const maticChildChainManagerProxyAddress = '0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa';
const mumbaiChildChainManagerProxyAddress = '0xb5505a6d998549090530911180f38aC5130101c6';

async function main() {
  const Okarys = await hre.ethers.getContractFactory('Okarys');
  const okarys = await Okarys.deploy(
    'Okarys',
    'https://ipfs.io/ipfs/QmPs2SxSoYgrpt8WGgkM8R8vojsXA9e6Gp5JWJ81bcMKw4/',
    '0x0000000000000000000000000000000000000000',
    0,
    mumbaiChildChainManagerProxyAddress,
  );

  await okarys.deployed();

  console.log('Okarys deployed to:', okarys.address);

  if (hre.network.name === 'mumbai') {
    await okarys.mint('0xC34B89d8C1ca7674e89AB5a9aC31F7Ceec31aEB5', 1, 3, '0x');
    console.log('Mint done');
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
