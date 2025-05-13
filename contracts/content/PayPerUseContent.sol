// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title PayPerUseContent
/// @notice Content requiring payment for each use
contract PayPerUseContent is OnChainStorage {
    uint256 internal usageCount;
    uint256 internal payment;

    modifier requiresPayment() {
        require(msg.value >= payment, "Payment required");
        _;
    }

    constructor(
        bytes memory chunk,
        uint256 _payment,
        address _owner,
        bool _finalized
    ) OnChainStorage(chunk, _owner, _finalized) {
        payment = _payment;
    }

    function getPayment() external view returns (uint256) {
        return payment;
    }

    function getUsageCount() external view returns (uint256) {
        return usageCount;
    }

    function use() external payable requiresPayment returns (bool) {
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(msg.value >= payment, "Payment required to view");
    }

    /// @notice Get content metadata (payment required)
    function getInfo()
        external
        payable
        requiresPayment
        returns (
            string memory name,
            string memory version,
            uint256 createdAt,
            string memory description
        )
    {
        return (info.name, info.version, info.createdAt, info.description);
    }

    /// @notice Get content assembly (payment required)
    function getContent() external payable requiresPayment returns (bytes memory) {
        return assemble();
    }

    /// @notice Get content as data URI (payment required)
    function getContentURI() external payable requiresPayment returns (string memory) {
        return stream();
    }

    /// @notice Get chunk count (payment required)
    function getChunkCount() external payable requiresPayment returns (uint256) {
        return chunkCount;
    }

    /// @notice Get chunk at specific index (payment required)
    function getChunk(uint256 index) external payable requiresPayment returns (bytes memory) {
        require(index < chunkCount, "Invalid chunk index");
        return chunks[index];
    }

    /// @notice Check if content is finalized (payment required)
    function isFinalized() external payable requiresPayment returns (bool) {
        return finalized;
    }
}
