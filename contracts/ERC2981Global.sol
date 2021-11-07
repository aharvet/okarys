// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

abstract contract ERC2981Global is IERC2981 {
    address public royaltyReceiver;
    // Expressed as an interger. Example: 30% would be 30
    uint256 public royaltyPercentage;

    /**
     * @param _royaltyPercentage Expressed as an interger. E.g. 30% would be 30
     */
    constructor(address _royaltyReceiver, uint256 _royaltyPercentage) {
        royaltyReceiver = _royaltyReceiver;
        royaltyPercentage = _royaltyPercentage;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC2981).interfaceId;
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        virtual
        override
        returns (address, uint256)
    {
        return (royaltyReceiver, (salePrice * royaltyPercentage) / 100);
    }
}
