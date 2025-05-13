// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title PayPerUseCappedContent
/// @notice Content requiring payment for each use with a maximum number of uses allowed
contract PayPerUseCappedContent is OnChainStorage {
    uint256 internal usageCount;
    uint256 internal payment;
    uint256 internal maxUsage;

    modifier requiresPaymentAndWithinLimit() {
        require(msg.value >= payment, "Payment required");
        require(usageCount < maxUsage, "Max access reached");
        _;
    }

    constructor(
        bytes memory chunk,
        uint256 _payment,
        uint256 _maxUsage,
        address _owner,
        bool _finalized
    ) OnChainStorage(chunk, _owner, _finalized) {
        payment = _payment;
        maxUsage = _maxUsage;
    }

    function getPayment() external view returns (uint256) {
        return payment;
    }

    function getMaxUsage() external view returns (uint256) {
        return maxUsage;
    }

    function getUsageCount() external view returns (uint256) {
        return usageCount;
    }

    function use() external payable requiresPaymentAndWithinLimit returns (bool) {
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(msg.value >= payment, "Payment required to view");
        require(usageCount < maxUsage, "Max access reached");
    }

    /// @notice Get content metadata (payment and usage limit required)
    function getInfo()
        external
        payable
        requiresPaymentAndWithinLimit
        returns (
            string memory name,
            string memory version,
            uint256 createdAt,
            string memory description
        )
    {
        return (info.name, info.version, info.createdAt, info.description);
    }

    /// @notice Get content assembly (payment and usage limit required)
    function getContent() external payable requiresPaymentAndWithinLimit returns (bytes memory) {
        return assemble();
    }

    /// @notice Get content as data URI (payment and usage limit required)
    function getContentURI() external payable requiresPaymentAndWithinLimit returns (string memory) {
        return stream();
    }

    /// @notice Get chunk count (payment and usage limit required)
    function getChunkCount() external payable requiresPaymentAndWithinLimit returns (uint256) {
        return chunkCount;
    }

    /// @notice Get chunk at specific index (payment and usage limit required)
    function getChunk(uint256 index) external payable requiresPaymentAndWithinLimit returns (bytes memory) {
        require(index < chunkCount, "Invalid chunk index");
        return chunks[index];
    }

    /// @notice Check if content is finalized (payment and usage limit required)
    function isFinalized() external payable requiresPaymentAndWithinLimit returns (bool) {
        return finalized;
    }
} 