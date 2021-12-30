// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ChildMintableERC1155.sol";
import "./ERC2981Global.sol";
import "./polygon/IChildToken.sol";

contract Okarys is ChildMintableERC1155, ERC2981Global, Ownable {
    using Strings for uint256;

    string public immutable name;

    constructor(
        string memory _name,
        string memory _uri,
        address royaltyReceiver,
        uint256 royaltyPercentage,
        address childChainManager
    )
        ERC1155(_uri)
        ChildMintableERC1155(childChainManager)
        ERC2981Global(royaltyReceiver, royaltyPercentage)
    {
        name = _name;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), id.toString(), ".json"));
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, ERC2981Global)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) || ERC2981Global.supportsInterface(interfaceId);
    }

    function setURI(string calldata _uri) external onlyOwner {
        _setURI(_uri);
    }
}
