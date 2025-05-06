// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IOnChainStorage
/// @notice Interface for all OnChainStorage content types
interface IOnChainStorage {
    /// @notice Returns the number of chunks stored
    function chunkCount() external view returns (uint256);

    /// @notice Returns a specific chunk at a given index
    /// @param index The index of the chunk
    /// @return The bytes content of the chunk
    function chunks(uint256 index) external view returns (bytes memory);

    /// @notice Returns whether the content is finalized
    function finalized() external view returns (bool);

    /// @notice Concatenates all chunks and returns the full assembled content
    /// @return The complete assembled content bytes
    function assemble() external view returns (bytes memory);

    /// @notice Returns a base64-encoded data URI of the content
    /// @return The data URI string
    function stream() external view returns (string memory);

    /// @notice Returns public metadata
    function info()
        external
        view
        returns (
            string memory name,
            string memory version,
            uint256 createdAt,
            string memory description
        );
}
