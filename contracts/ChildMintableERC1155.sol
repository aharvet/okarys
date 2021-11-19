// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./polygon/IChildToken.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

abstract contract ChildMintableERC1155 is IChildToken, ERC1155Supply {
    // Polygon bridge
    address private childChainManager;

    modifier onlyChildChainManager() {
        require(msg.sender == childChainManager, "Okarys: access denied");
        _;
    }

    constructor(address _childChainManager) {
        childChainManager = _childChainManager;
    }

    /**
     * @notice called when tokens are deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required tokens for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded ids array and amounts array
     */
    function deposit(address user, bytes calldata depositData)
        external
        override
        onlyChildChainManager
    {
        (uint256[] memory ids, uint256[] memory amounts, bytes memory data) = abi.decode(
            depositData,
            (uint256[], uint256[], bytes)
        );
        require(user != address(0), "ChildMintableERC1155: invalid deposit user");
        _mintBatch(user, ids, amounts, data);
    }

    /**
     * @notice called when user wants to withdraw single token back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param id id to withdraw
     * @param amount amount to withdraw
     */
    function withdrawSingle(uint256 id, uint256 amount) external {
        _burn(msg.sender, id, amount);
    }

    /**
     * @notice called when user wants to batch withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param ids ids to withdraw
     * @param amounts amounts to withdraw
     */
    function withdrawBatch(uint256[] calldata ids, uint256[] calldata amounts) external {
        _burnBatch(msg.sender, ids, amounts);
    }
}
