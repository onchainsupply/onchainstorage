// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OnChainCodec} from "./OnChainCodec.sol";

/// @title ONCHAINSUPPLY:CORE
/// @notice Abstract base for all chunked onchain storage contracts under OCS standard
abstract contract OnChainCore is Ownable {
    /// @notice Number of chunks stored
    uint256 public chunkCount;

    /// @notice Storage for chunked data
    mapping(uint256 => bytes) public chunks;

    /// @notice Finalization flag indicating immutability
    bool public finalized;

    /// @notice Metadata structure
    struct Info {
        string name;
        string version;
        uint256 createdAt;
        string description;
    }

    /// @notice Public info for UI and indexers
    Info public info;

    /// @dev Emitted when info is updated
    event InfoUpdated(string name, string version, string description);
    /// @dev Emitted when finalized
    event Finalized();
    /// @dev Emitted when reset is triggered
    event Reset();
    /// @dev Emitted when chunks are appended
    event ChunksAppended(uint256 count);

    /// @notice Core constructor initializes owner and first chunk
    constructor(bytes memory initialChunk, address _owner) Ownable(_owner) {
        chunks[0] = initialChunk;
        chunkCount = 1;
        info.createdAt = block.timestamp;
    }

    /// @notice Extend with additional data chunks
    /// @param data Array of byte chunks to store
    function extend(bytes[] calldata data) external onlyOwner {
        require(!finalized, "Finalized");
        for (uint256 i = 0; i < data.length; i++) {
            chunks[chunkCount] = data[i];
            chunkCount++;
        }
        emit ChunksAppended(data.length);
    }

    /// @notice Prevent further changes
    function finalize() external onlyOwner {
        finalized = true;
        emit Finalized();
    }

    /// @notice Purge all stored chunks and reset state
    function purge() external onlyOwner {
        for (uint256 i = 0; i < chunkCount; i++) {
            delete chunks[i];
        }
        chunkCount = 0;
        finalized = false;
        emit Reset();
    }

    /// @notice Label or update metadata fields
    function label(
        string calldata name,
        string calldata version,
        string calldata description
    ) external onlyOwner {
        info.name = name;
        info.version = version;
        info.description = description;
        emit InfoUpdated(name, version, description);
    }

    /// @notice View assembled output from all chunks
    /// @return output Concatenated asset bytes
    function assemble() public view virtual returns (bytes memory output) {
        require(finalized, "Not finalized");
        for (uint256 i = 0; i < chunkCount; i++) {
            output = bytes.concat(output, chunks[i]);
        }
    }

    /// @notice View assembled output as base64-encoded data URI (RFC 2397)
    /// @return base64Stream Data URI containing base64 content
    function stream() public view virtual returns (string memory base64Stream) {
        bytes memory fullData = assemble();
        base64Stream = OnChainCodec.encodeOctetStream(fullData);
    }
}
