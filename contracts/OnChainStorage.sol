// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OnChainCodec} from "./utils/OnChainCodec.sol";

/// @title ONCHAINSUPPLY:STORAGE
/// @notice Abstract base contract for managing and storing finalized onchain content in chunked form.
abstract contract OnChainStorage is Ownable {
    /// @notice Tracks the number of content chunks appended
    uint256 internal chunkCount;

    /// @notice Mapping from chunk index to actual chunk data
    mapping(uint256 => bytes) internal chunks;

    /// @notice Total size in bytes of all content chunks
    uint256 internal totalSize;

    /// @notice Flag to lock the content against further modification
    bool internal finalized;

    /// @notice Metadata container describing the content
    struct Info {
        string name;
        string version;
        string mimeType;
        uint256 createdAt;
        string description;
    }

    /// @notice Public content metadata
    Info internal info;

    /// @dev Emitted when content metadata is updated
    event InfoUpdated(string name, string version, string description);

    /// @dev Emitted when content is marked as finalized
    event Finalized();

    /// @dev Emitted when content chunks are purged
    event Reset();

    /// @dev Emitted when new content chunks are added
    event ChunksAppended(uint256 count);

    /// @param initialChunk First content chunk to initialize with
    /// @param _owner Address that will own and control the content
    /// @param _finalized Whether to finalize content on creation
    constructor(
        string memory mimeType,
        bytes memory initialChunk,
        address _owner,
        bool _finalized
    ) Ownable(_owner) {
        info.mimeType = mimeType;
        chunks[0] = initialChunk;
        chunkCount = 1;
        totalSize = initialChunk.length;
        finalized = _finalized;
        info.createdAt = block.timestamp;
        if (_finalized) {
            emit Finalized();
        }
    }

    /// @notice Modifier that restricts access using internal authorization logic
    modifier authorized() {
        authorizeViewer();
        _;
    }

    /// @notice Hook to enforce access control logic in subclasses
    function authorizeViewer() internal view virtual {
        // Default: open access
    }

    /// @notice Appends additional content chunks before finalization
    /// @param data Array of byte chunks to append
    function extend(bytes[] calldata data) external onlyOwner {
        require(!finalized, "Content is finalized");
        for (uint256 i = 0; i < data.length; i++) {
            chunks[chunkCount] = data[i];
            totalSize += data[i].length;
            chunkCount++;
        }
        emit ChunksAppended(data.length);
    }

    /// @notice Finalizes content to prevent any further changes
    function finalize() external onlyOwner {
        finalized = true;
        emit Finalized();
    }

    /// @notice Deletes all stored chunks and resets state (only if not finalized)
    function purge() external onlyOwner {
        for (uint256 i = 0; i < chunkCount; i++) {
            delete chunks[i];
        }
        chunkCount = 0;
        totalSize = 0;
        finalized = false;
        emit Reset();
    }

    /// @notice Returns the total size in bytes of stored content
    function size() public view returns (uint256) {
        return totalSize;
    }

    /// @notice Updates metadata information for the content
    /// @param name Descriptive name for the content
    /// @param version Optional version indicator
    /// @param description Short description of content purpose
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

    /// @notice Concatenates all content chunks into one complete byte array
    /// @return output Final assembled byte stream
    function assemble()
        internal
        view
        virtual
        authorized
        returns (bytes memory output)
    {
        require(finalized, "Content not finalized");
        for (uint256 i = 0; i < chunkCount; i++) {
            output = bytes.concat(output, chunks[i]);
        }
    }

    /// @notice Encodes full content as base64 RFC 2397 octet-stream data URI
    /// @return base64Stream Base64-encoded data URI string
    function stream()
        internal
        view
        virtual
        authorized
        returns (string memory base64Stream)
    {
        bytes memory fullData = assemble();
        string memory mimeType = info.mimeType;
        base64Stream = OnChainCodec.encodeWithMime(mimeType, fullData);
    }
}
