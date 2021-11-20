const { ethers } = require('hardhat');

function constructERC1155DepositData(ids, amounts) {
  return ethers.utils.defaultAbiCoder.encode(
    ['uint256[]', 'uint256[]', 'bytes'],
    [ids.map((id) => id.toString()), amounts.map((amount) => amount.toString()), '0x'],
  );
}

module.exports = { constructERC1155DepositData };
