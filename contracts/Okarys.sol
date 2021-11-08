// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981Global.sol";

// TODO Check return of URI, must be with hexadecimal id

contract Okarys is ERC165, IERC1155, IERC1155MetadataURI, ERC2981Global, Ownable {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;
    // Mapping from token ID to supply
    mapping(uint256 => uint256) private _totalSupply;
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all tokens by relying on ID substitution
    string private baseUri;

    event BaseUriUpdated(string newBaseUri);

    constructor(
        string memory _baseUri,
        address royaltyReceiver,
        uint256 royaltyPercentage
    ) ERC2981Global(royaltyReceiver, royaltyPercentage) {
        baseUri = _baseUri;
    }

    /**
     * @return baseUri
     * Needs to be concatenated with token ID
     * E.g. https://token-cdn-domain/314592.json if the client is referring to token ID 314592
     */
    function uri(uint256) external view override returns (string memory) {
        return baseUri;
    }

    function exists(uint256 id) external view returns (bool) {
        return totalSupply(id) > 0;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        external
        view
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external override {
        require(msg.sender != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: transfer caller is not owner nor approved"
        );
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function setUri(string memory newBaseUri) external onlyOwner {
        baseUri = newBaseUri;
        emit BaseUriUpdated(newBaseUri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external onlyOwner {
        require(account != address(0), "ERC1155: mint to the zero address");
        require(_totalSupply[id] < 150, "ERC1155: cannot mint more than 149 tokens");

        address operator = msg.sender;

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
        _totalSupply[id] += amount;
    }

    /**
     * @notice Mints multiple tokens for the same address
     */
    function mintBatch(
        address account,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external onlyOwner {
        require(account != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; i++) {
            require(_totalSupply[ids[i]] < 150, "ERC1155: cannot mint more than 149 tokens");
            _balances[ids[i]][account] += amounts[i];
            _totalSupply[ids[i]] += amounts[i];
        }

        emit TransferBatch(operator, address(0), account, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), account, ids, amounts, data);
    }

    /**
     * @notice Mints multiple tokens for multiple addresses
     */
    function multiMint(
        address[] calldata accounts,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external onlyOwner {
        require(
            accounts.length == ids.length && ids.length == amounts.length,
            "ERC1155: accounts, ids and amounts length mismatch"
        );

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; i++) {
            require(accounts[i] != address(0), "ERC1155: mint to the zero address");
            require(_totalSupply[ids[i]] < 150, "ERC1155: cannot mint more than 149 tokens");

            _balances[ids[i]][accounts[i]] += amounts[i];
            _totalSupply[ids[i]] += amounts[i];

            emit TransferSingle(operator, address(0), accounts[i], ids[i], amounts[i]);
            _doSafeTransferAcceptanceCheck(
                operator,
                address(0),
                accounts[i],
                ids[i],
                amounts[i],
                data
            );
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC165, IERC165, ERC2981Global)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            ERC2981Global.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function isApprovedForAll(address account, address operator)
        public
        view
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data)
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
