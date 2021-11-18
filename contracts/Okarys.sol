// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981Global.sol";

contract Okarys is ERC1155Supply, ERC2981Global, Ownable {
    event RoyaltyReceiverUpdated(address newReceiver);
    event RoyaltyPercentageUpdated(uint256 newPercentage);

    constructor(
        string memory uri,
        address royaltyReceiver,
        uint256 royaltyPercentage
    ) ERC1155(uri) ERC2981Global(royaltyReceiver, royaltyPercentage) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, ERC2981Global)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) || ERC2981Global.supportsInterface(interfaceId);
    }

    function setURI(string calldata uri) external onlyOwner {
        super._setURI(uri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        require(totalSupply(id) + amount < 150, "OKARYS: Supply of each token is limited to 149");
        super._mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyOwner {
        for (uint256 i = 0; i < ids.length; ++i) {
            require(
                totalSupply(ids[i]) + amounts[i] < 150,
                "OKARYS: Supply of each token is limited to 149"
            );
        }
        super._mintBatch(to, ids, amounts, data);
    }

    function setRoyaltyReceiver(address receiver) external onlyOwner {
        royaltyReceiver = receiver;
        emit RoyaltyReceiverUpdated(receiver);
    }

    function setRoyaltyPercentage(uint256 percentage) external onlyOwner {
        royaltyPercentage = percentage;
        emit RoyaltyPercentageUpdated(percentage);
    }
}
