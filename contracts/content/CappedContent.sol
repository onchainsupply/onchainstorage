// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title CappedContent
/// @notice Content with a maximum number of uses allowed
contract CappedContent is OnChainStorage {
    uint256 internal usageCount;
    uint256 internal maxUsage;

    modifier withinUsageLimit() {
        require(usageCount < maxUsage, "Max access reached");
        _;
    }

    constructor(
        string memory mimeType,
        bytes memory chunk,
        uint256 _maxUsage,
        address _owner,
        bool _finalized
    ) OnChainStorage(mimeType, chunk, _owner, _finalized) {
        maxUsage = _maxUsage;
    }

    function getMaxUsage() external view returns (uint256) {
        return maxUsage;
    }

    function getUsageCount() external view returns (uint256) {
        return usageCount;
    }

    function use() external withinUsageLimit returns (bool) {
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(usageCount < maxUsage, "Max access reached");
    }

    /// @notice Get content metadata (usage capped)
    function getInfo()
        external
        view
        withinUsageLimit
        returns (
            string memory name,
            string memory version,
            string memory mimeType,
            uint256 createdAt,
            string memory description
        )
    {
        return (
            info.name,
            info.version,
            info.mimeType,
            info.createdAt,
            info.description
        );
    }

    /// @notice Get content assembly (usage capped)
    function getContent()
        external
        view
        withinUsageLimit
        returns (bytes memory)
    {
        return assemble();
    }

    /// @notice Get content as data URI (usage capped)
    function getContentURI()
        external
        view
        withinUsageLimit
        returns (string memory)
    {
        return stream();
    }

    /// @notice Get chunk count (usage capped)
    function getChunkCount() external view withinUsageLimit returns (uint256) {
        return chunkCount;
    }

    /// @notice Get chunk at specific index (usage capped)
    function getChunk(
        uint256 index
    ) external view withinUsageLimit returns (bytes memory) {
        require(index < chunkCount, "Invalid chunk index");
        return chunks[index];
    }

    /// @notice Check if content is finalized (usage capped)
    function isFinalized() external view withinUsageLimit returns (bool) {
        return finalized;
    }
}
