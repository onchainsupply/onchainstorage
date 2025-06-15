// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title BasicContent
/// @notice Open-access content with no usage limits or fees
contract PublicContent is OnChainStorage {
    uint256 internal usageCount;
    address[] public users;

    event Withdrawn(address indexed to, uint256 amount);
    event TokenWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    constructor(
        string memory mimeType,
        bytes memory chunk,
        address _owner,
        bool _finalized,
        address _factory
    ) OnChainStorage(mimeType, chunk, _owner, _finalized, _factory) {}

    /// @notice Register content use (unrestricted)
    function use() external returns (bool) {
        usageCount++;
        users.push(msg.sender);
        return true;
    }

    /// @notice Get current usage count
    function getUsageCount() external view returns (uint256) {
        return usageCount;
    }

    /// @notice Get content metadata
    function getInfo()
        external
        view
        returns (
            string memory name,
            address totalSize,
            string memory version,
            string memory mimeType,
            uint256 createdAt,
            string memory description,
            uint256 totalBytes
        )
    {
        return (
            info.name,
            owner(),
            info.version,
            info.mimeType,
            info.createdAt,
            info.description,
            size()
        );
    }

    /// @notice Get content assembly
    function getContent() external view returns (bytes memory) {
        return assemble();
    }

    /// @notice Get content as data URI
    function getContentURI() external view returns (string memory) {
        return stream();
    }

    /// @notice Get chunk count
    function getChunkCount() external view returns (uint256) {
        return chunkCount;
    }

    /// @notice Get chunk at specific index
    function getChunk(uint256 index) external view returns (bytes memory) {
        require(index < chunkCount, "Invalid chunk index");
        return chunks[index];
    }

    /// @notice Check if content is finalized
    function isFinalized() external view returns (bool) {
        return finalized;
    }

    /// @notice Withdraw collected ETH with 5% fee sent to factory
    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH to withdraw");
        uint256 fee = (amount * 5) / 100;
        uint256 payout = amount - fee;
        if (fee > 0) {
            payable(factory).transfer(fee);
        }
        payable(owner()).transfer(payout);
        emit Withdrawn(owner(), payout);
    }

    /// @notice Withdraw any ERC20 tokens sent to the contract with 5% fee to factory
    function withdrawToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No token balance");
        uint256 fee = (balance * 5) / 100;
        uint256 payout = balance - fee;
        if (fee > 0) {
            require(
                IERC20(token).transfer(factory, fee),
                "Token fee transfer failed"
            );
        }
        require(
            IERC20(token).transfer(owner(), payout),
            "Token transfer failed"
        );
        emit TokenWithdrawn(token, owner(), payout);
    }

    receive() external payable {}
}
