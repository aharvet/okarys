const { expect } = require('chai');
const { ethers } = require('hardhat');
const { constructERC1155DepositData } = require('./utils');

describe('Okarys', function () {
  let owner, childChainManager, royaltyReceiver, user1, user2;
  let okarys;
  const royaltyPercentage = 15;
  const baseUri = 'http://base-uri-path.com/';

  before(async () => {
    [owner, childChainManager, royaltyReceiver, user1, user2] = await ethers.getSigners();
  });

  beforeEach(async () => {
    const Okarys = await ethers.getContractFactory('Okarys');
    okarys = await Okarys.deploy(
      baseUri,
      royaltyReceiver.address,
      royaltyPercentage,
      childChainManager.address,
    );
  });

  describe('Interface Ids', () => {
    it('should support ERC165 interface', async () => {
      expect(await okarys.supportsInterface('0x01ffc9a7')).to.be.true;
    });

    it('should support ERC2981 interface', async () => {
      expect(await okarys.supportsInterface('0x2a55205a')).to.be.true;
    });

    it('should support ERC1155 interface', async () => {
      expect(await okarys.supportsInterface('0xd9b67a26')).to.be.true;
    });
    it('should support IERC1155MetadataURI interface', async () => {
      expect(await okarys.supportsInterface('0x0e89341c')).to.be.true;
    });
  });

  describe('URI', () => {
    it('should set URI at deployment', async function () {
      const id = '0';
      expect(await okarys.uri(id)).equal(baseUri + id + '.json');
    });

    it('should return correct uri', async () => {
      const id = '325';
      expect(await okarys.uri(325)).equal(baseUri + id + '.json');
    });

    it('should update URI', async function () {
      const newUri = 'newURI';
      const id = '3';
      await okarys.setURI(newUri);
      expect(await okarys.uri(id)).equal(newUri + id + '.json');
    });

    it('should not update URI if not owner', async function () {
      await expect(okarys.connect(user1).setURI('newURI')).to.be.revertedWith(
        'Ownable: caller is not the owner',
      );
    });
  });

  describe('Minting', () => {
    describe('Mint', () => {
      const id = 255;

      it('should mint a token', async () => {
        const amount = 4;
        await okarys.mint(user1.address, id, amount, '0x');
        expect(await okarys.balanceOf(user1.address, id)).equal(amount);
      });

      it('should not mint if not owner', async () => {
        await expect(okarys.connect(user1).mint(user1.address, id, 4, '0x')).to.be.revertedWith(
          'Ownable: caller is not the owner',
        );
      });

      it('should not mint more than 149 tokens', async () => {
        await expect(okarys.mint(user1.address, id, 150, '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });

      it('should not mint if total supply for user is more than 149 tokens', async () => {
        await okarys.mint(user1.address, id, 120, '0x');
        await expect(okarys.mint(user1.address, id, 30, '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });

      it('should not mint if total supply accross users is more than 149 tokens', async () => {
        await okarys.mint(user1.address, id, 20, '0x');
        await okarys.mint(user2.address, id, 20, '0x');
        await expect(okarys.mint(user1.address, id, 110, '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });
    });

    describe('MintBatch', () => {
      const ids = [30, 256];
      const amounts = [4, 58];

      it('should mintBatch tokens', async () => {
        await okarys.mintBatch(user1.address, ids, amounts, '0x');
        ids.forEach(async (id, index) => {
          expect(await okarys.balanceOf(user1.address, id)).equal(amounts[index]);
        });
      });

      it('should not mintBatch if not owner', async () => {
        await expect(
          okarys.connect(user2).mintBatch(user1.address, ids, amounts, '0x'),
        ).to.be.revertedWith('Ownable: caller is not the owner');
      });

      it('should not mintBatch more than 149 tokens', async () => {
        await expect(okarys.mintBatch(user1.address, ids, [3, 150], '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });

      it('should not mintBatch if total supply for user is more than 149 tokens', async () => {
        await okarys.mint(user1.address, ids[0], 120, '0x');
        await expect(okarys.mintBatch(user1.address, ids, [30, 50], '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });

      it('should not mintBatch if total supply accross users is more than 149 tokens', async () => {
        await okarys.mint(user1.address, ids[0], 20, '0x');
        await okarys.mint(user2.address, ids[0], 20, '0x');
        await expect(okarys.mintBatch(user1.address, ids, [110, 50], '0x')).to.be.revertedWith(
          'Okary: Supply of each token is limited to 149',
        );
      });
    });
  });

  describe('Royalty', () => {
    const id = 34;
    const price = 100;

    it('should set royalty infos at deployment', async () => {
      const expectRoyaltyAmount = (price * royaltyPercentage) / 100;
      const royaltyInfo = await okarys.royaltyInfo(id, price);
      expect(royaltyInfo[0]).equal(royaltyReceiver.address);
      expect(royaltyInfo[1]).equal(expectRoyaltyAmount);
    });

    it('should update royalty receiver', async () => {
      await expect(okarys.setRoyaltyReceiver(user2.address))
        .to.emit(okarys, 'RoyaltyReceiverUpdated')
        .withArgs(user2.address);
      expect((await okarys.royaltyInfo(id, price))[0]).equal(user2.address);
    });

    it('should not update royalty receiver if not owner', async () => {
      await expect(okarys.connect(user1).setRoyaltyReceiver(user2.address)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      );
    });

    it('should update royalty percentage', async () => {
      const newRoyaltyPercentage = 30;
      const expectRoyaltyAmount = (price * newRoyaltyPercentage) / 100;
      await expect(okarys.setRoyaltyPercentage(newRoyaltyPercentage))
        .to.emit(okarys, 'RoyaltyPercentageUpdated')
        .withArgs(newRoyaltyPercentage);
      expect((await okarys.royaltyInfo(id, price))[1]).equal(expectRoyaltyAmount);
    });

    it('should not update royalty percentage if not owner', async () => {
      await expect(okarys.connect(user1).setRoyaltyPercentage(40)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      );
    });
  });

  describe('Polygon bridge', () => {
    const firstTokenId = 3;
    const secondTokenId = 64;
    const firstAmount = 1;
    const secondAmount = 8;

    describe('Deposit', () => {
      it('should deposit one token', async () => {
        const depositData = constructERC1155DepositData([firstTokenId], [firstAmount]);
        await okarys.connect(childChainManager).deposit(user1.address, depositData);
        expect(await okarys.balanceOf(user1.address, firstTokenId)).equal(firstAmount);
      });

      it('should deposit several tokens', async () => {
        const depositData = constructERC1155DepositData(
          [firstTokenId, secondTokenId],
          [firstAmount, secondAmount],
        );
        await okarys.connect(childChainManager).deposit(user1.address, depositData);
        expect(await okarys.balanceOf(user1.address, firstTokenId)).equal(firstAmount);
        expect(await okarys.balanceOf(user1.address, secondTokenId)).equal(secondAmount);
      });

      it('should not deposit tokens if not depositor', async () => {
        const depositData = constructERC1155DepositData([firstTokenId], [firstAmount]);
        await expect(okarys.connect(user2).deposit(user1.address, depositData)).to.be.revertedWith(
          'Okarys: caller is not the depositor',
        );
      });

      it('should not deposit tokens if user is zero address', async () => {
        const depositData = constructERC1155DepositData([firstTokenId], [firstAmount]);
        await expect(
          okarys
            .connect(childChainManager)
            .deposit('0x0000000000000000000000000000000000000000', depositData),
        ).to.be.revertedWith('ChildMintableERC1155: invalid deposit user');
      });
    });

    describe('Withdraw', () => {
      beforeEach(async () => {
        await okarys.mintBatch(
          user1.address,
          [firstTokenId, secondTokenId],
          [firstAmount, secondAmount],
          '0x',
        );
      });

      it('should withdraw one token', async () => {
        const amountWithdrew = 1;
        await okarys.connect(user1).withdrawSingle(secondTokenId, amountWithdrew);
        expect(await okarys.balanceOf(user1.address, secondTokenId)).equal(
          secondAmount - amountWithdrew,
        );
      });

      it('should withdraw severals tokens', async () => {
        const firstAmountWithdrew = 1;
        const secondAmountWithdrew = 4;
        await okarys
          .connect(user1)
          .withdrawBatch(
            [firstTokenId, secondTokenId],
            [firstAmountWithdrew, secondAmountWithdrew],
          );
        expect(await okarys.balanceOf(user1.address, firstTokenId)).equal(
          firstAmount - firstAmountWithdrew,
        );
        expect(await okarys.balanceOf(user1.address, secondTokenId)).equal(
          secondAmount - secondAmountWithdrew,
        );
      });

      it('should not withdraw more tokens than held', async () => {
        const amountWithdrew = 4;
        await expect(
          okarys.connect(user1).withdrawSingle(firstTokenId, amountWithdrew),
        ).to.be.revertedWith(
          'VM Exception while processing transaction: reverted with panic code 0x11 (Arithmetic operation underflowed or overflowed outside of an unchecked block)',
        );
      });
    });
  });
});
