// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981Global.sol";

contract Okarys is ERC1155Supply, ERC2981Global, Ownable {
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
        _setURI(uri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        require(totalSupply(id) + amount < 150, "Okary: Supply of each token is limited to 149");
        _mint(account, id, amount, data);
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
                "Okary: Supply of each token is limited to 149"
            );
        }
        _mintBatch(to, ids, amounts, data);
    }

    function setRoyaltyReceiver(address receiver) external onlyOwner {
        _setRoyaltyReceiver(receiver);
    }

    function setRoyaltyPercentage(uint256 percentage) external onlyOwner {
        _setRoyaltyPercentage(percentage);
    }
}
