const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ERC2981Global', function () {
  let deployer, royaltyReceiver, user;
  let royaltyPercentage;
  let mockERC2981Global;

  before(async () => {
    [deployer, royaltyReceiver, user] = await ethers.getSigners();
    royaltyPercentage = 15;
  });

  beforeEach(async () => {
    const MockERC2981Global = await ethers.getContractFactory('MockERC2981Global');
    mockERC2981Global = await MockERC2981Global.deploy(royaltyReceiver.address, royaltyPercentage);
  });

  it('should set receiver at deployment', async () => {
    expect(await mockERC2981Global.royaltyReceiver()).equal(royaltyReceiver.address);
  });

  it('should set percentage at deployment', async () => {
    expect(await mockERC2981Global.royaltyPercentage()).equal(royaltyPercentage);
  });

  it('should return correct royalty info', async () => {
    const salePrice = 1000000000;
    const royaltyInfo = await mockERC2981Global.royaltyInfo(0, salePrice);
    expect(royaltyInfo[0]).equal(royaltyReceiver.address);
    expect(royaltyInfo[1]).equal((salePrice * royaltyPercentage) / 100);
  });

  it('should support ERC165 interface', async () => {
    expect(await mockERC2981Global.supportsInterface('0x01ffc9a7')).to.be.true;
  });

  it('should support ERC2981 interface', async () => {
    expect(await mockERC2981Global.supportsInterface('0x2a55205a')).to.be.true;
  });
});
