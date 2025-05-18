// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title WhitelistContent
/// @notice Content restricted to a whitelist of allowed addresses
contract WhitelistContent is OnChainStorage {
    uint256 internal usageCount;
    mapping(address => bool) internal whitelist;

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    constructor(
        string memory mimeType,
        bytes memory chunk,
        address _owner,
        bool _finalized
    ) OnChainStorage(mimeType, chunk, _owner, _finalized) {}

    function addToWhitelist(address user) external onlyOwner {
        whitelist[user] = true;
    }

    function removeFromWhitelist(address user) external onlyOwner {
        whitelist[user] = false;
    }

    function isWhitelisted(address user) external view returns (bool) {
        return whitelist[user];
    }

    function getUsageCount() external view returns (uint256) {
        return usageCount;
    }

    function use() external onlyWhitelisted returns (bool) {
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(whitelist[msg.sender], "Access denied");
    }

    /// @notice Get content metadata (whitelist restricted)
    function getInfo()
        external
        view
        onlyWhitelisted
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

    /// @notice Get content assembly (whitelist restricted)
    function getContent() external view onlyWhitelisted returns (bytes memory) {
        return assemble();
    }

    /// @notice Get content as data URI (whitelist restricted)
    function getContentURI()
        external
        view
        onlyWhitelisted
        returns (string memory)
    {
        return stream();
    }

    /// @notice Get chunk count (whitelist restricted)
    function getChunkCount() external view onlyWhitelisted returns (uint256) {
        return chunkCount;
    }

    /// @notice Get chunk at specific index (whitelist restricted)
    function getChunk(
        uint256 index
    ) external view onlyWhitelisted returns (bytes memory) {
        require(index < chunkCount, "Invalid chunk index");
        return chunks[index];
    }

    /// @notice Check if content is finalized (whitelist restricted)
    function isFinalized() external view onlyWhitelisted returns (bool) {
        return finalized;
    }
}
