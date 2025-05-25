// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title BasicContent
/// @notice Open-access content with no usage limits or fees
contract BasicContent is OnChainStorage {
    uint256 internal usageCount;
    address[] public users;

    constructor(
        string memory mimeType,
        bytes memory chunk,
        address _owner,
        bool _finalized
    ) OnChainStorage(mimeType, chunk, _owner, _finalized) {}

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
            address owner,
            string memory version,
            string memory mimeType,
            uint256 createdAt,
            string memory description,
            uint256 totalSize
        )
    {
        return (
            info.name,
            owner(),
            info.version,
            info.mimeType,
            info.createdAt,
            info.description,
            totalSize
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
}
