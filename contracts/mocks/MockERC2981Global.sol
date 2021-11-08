// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../ERC2981Global.sol";

contract MockERC2981Global is ERC2981Global {
    constructor(address royaltyReceiver, uint256 royaltyPercentage)
        ERC2981Global(royaltyReceiver, royaltyPercentage)
    {}
}
