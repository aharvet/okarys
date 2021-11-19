// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ChildMintableERC1155.sol";
import "./ERC2981Global.sol";
import "./polygon/IChildToken.sol";

contract Okarys is ChildMintableERC1155, ERC2981Global, Ownable {
    constructor(
        string memory _uri,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        address _childChainManager
    )
        ERC1155(_uri)
        ChildMintableERC1155(_childChainManager)
        ERC2981Global(_royaltyReceiver, _royaltyPercentage)
    {}

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
