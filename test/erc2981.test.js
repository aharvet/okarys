const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ERC2981Global', function () {
  let deployer, royaltyReceiver, user;
  let royaltyPercentage;
  let okary;

  before(async () => {
    [deployer, royaltyReceiver, user] = await ethers.getSigners();
    royaltyPercentage = 15;
  });

  beforeEach(async () => {
    const Okarys = await ethers.getContractFactory('Okarys');
    okary = await Okarys.deploy('', royaltyReceiver.address, royaltyPercentage);
  });

  it('should set receiver at deployment', async () => {
    expect(await okary.royaltyReceiver()).equal(royaltyReceiver.address);
  });

  it('should set percentage at deployment', async () => {
    expect(await okary.royaltyPercentage()).equal(royaltyPercentage);
  });

  it('should return correct royalty info', async () => {
    const salePrice = 1000000000;
    const royaltyInfo = await okary.royaltyInfo(0, salePrice);
    expect(royaltyInfo[0]).equal(royaltyReceiver.address);
    expect(royaltyInfo[1]).equal((salePrice * royaltyPercentage) / 100);
  });

  it('should support ERC165 interface', async () => {
    expect(await okary.supportsInterface('0x01ffc9a7')).to.be.true;
  });

  it('should support ERC2981 interface', async () => {
    expect(await okary.supportsInterface('0x2a55205a')).to.be.true;
  });
});
