const hre = require('hardhat');

const maticChildChainManagerProxyAddress = '0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa';
const mumbaiChildChainManagerProxyAddress = '0xb5505a6d998549090530911180f38aC5130101c6';

async function main() {
  const Okarys = await hre.ethers.getContractFactory('Okarys');
  const okarys = await Okarys.deploy(
    'Okarys',
    'http://base-uri-path.com/',
    '0x0000000000000000000000000000000000000000',
    0,
    mumbaiChildChainManagerProxyAddress,
  );

  await okarys.deployed();

  console.log('Okarys deployed to:', okarys.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
