const { expect } = require('chai');
const { ethers, waffle } = require('hardhat');
const { provider } = waffle;

const { ZERO_ADDRESS, storageToString } = require('./utils');

describe('Okarys', function () {
  let owner, user;
  let okarys;
  let baseUri;

  before(async () => {
    [owner, royaltyReceiver, user] = await ethers.getSigners();
    baseUri = 'http://base-uri-path.com/';
  });

  beforeEach(async () => {
    const Okarys = await ethers.getContractFactory('Okarys');
    okarys = await Okarys.deploy(baseUri, ZERO_ADDRESS, 0);
  });

  it('should set baseUri at deployment', async function () {
    const storage = await provider.getStorageAt(okarys.address, 6);
    expect(storageToString(storage)).equal(baseUri);
  });

  it('should return base URI', async function () {
    expect(await okarys.uri(0)).equal(baseUri);
  });
});

// setUri

// mint

// multipleMint

// 149 exemplaires
