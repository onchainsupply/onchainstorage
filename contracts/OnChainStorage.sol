// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OnChainCodec} from "./utils/OnChainCodec.sol";

/// @title ONCHAINSUPPLY:STORAGE
/// @notice Abstract base contract for managing and storing finalized onchain content in chunked form.
abstract contract OnChainStorage is Ownable {
    uint256 internal chunkCount;
    mapping(uint256 => bytes) internal chunks;
    uint256 internal totalSize;
    bool internal finalized;
    address internal factory;

    struct Info {
        string name;
        string version;
        string mimeType;
        uint256 createdAt;
        string description;
    }

    Info internal info;

    event InfoUpdated(string name, string version, string description);
    event Finalized();
    event Reset();
    event ChunksAppended(uint256 count);
    event AuthorizationGranted(address indexed executor);
    event AuthorizationRevoked(address indexed executor);

    /// @notice Mapping to track authorized executors (relayers, agents, etc.)
    mapping(address => bool) internal isAuthorized;

    /// @notice Modifier to restrict access to owner or gasless execution agents
    modifier onlyAuthorized() {
        require(
            owner() == msg.sender || isAuthorized[msg.sender],
            "Unauthorized caller"
        );
        _;
    }

    modifier notFinalized() {
        require(!finalized, "Content is finalized");
        _;
    }

    modifier onlyFinalized() {
        require(finalized, "Content not finalized");
        _;
    }

    constructor(
        string memory mimeType,
        bytes memory initialChunk,
        address _owner,
        bool _finalized,
        address _factory
    ) Ownable(_owner) {
        chunks[0] = initialChunk;
        chunkCount = 1;
        totalSize = initialChunk.length;
        finalized = _finalized;
        info.mimeType = mimeType;
        info.createdAt = block.timestamp;
        factory = _registry;

        if (_finalized) emit Finalized();
    }

    /// -------------------------------
    /// 🔑 AUTHORIZATION MANAGEMENT
    /// -------------------------------

    function grantAuthorization(address executor) external onlyOwner {
        isAuthorized[executor] = true;
        emit AuthorizationGranted(executor);
    }

    function revokeAuthorization(address executor) external onlyOwner {
        isAuthorized[executor] = false;
        emit AuthorizationRevoked(executor);
    }

    function isExecutorAuthorized(address executor) public view returns (bool) {
        return isAuthorized[executor];
    }

    /// -------------------------------
    /// ✍️ WRITING / MODIFYING CONTENT
    /// -------------------------------

    function extend(
        bytes[] calldata data
    ) external onlyAuthorized notFinalized {
        for (uint256 i = 0; i < data.length; i++) {
            chunks[chunkCount] = data[i];
            totalSize += data[i].length;
            chunkCount++;
        }
        emit ChunksAppended(data.length);
    }

    function finalize() external onlyAuthorized notFinalized {
        finalized = true;
        emit Finalized();
    }

    function purge() external onlyAuthorized {
        for (uint256 i = 0; i < chunkCount; i++) {
            delete chunks[i];
        }
        chunkCount = 0;
        totalSize = 0;
        finalized = false;
        emit Reset();
    }

    function label(
        string calldata name,
        string calldata version,
        string calldata description
    ) external onlyAuthorized {
        info.name = name;
        info.version = version;
        info.description = description;
        emit InfoUpdated(name, version, description);
    }

    /// -------------------------------
    /// 🔍 VIEWING CONTENT
    /// -------------------------------

    function size() public view returns (uint256) {
        return totalSize;
    }

    function assemble()
        internal
        view
        virtual
        onlyFinalized
        returns (bytes memory output)
    {
        for (uint256 i = 0; i < chunkCount; i++) {
            output = bytes.concat(output, chunks[i]);
        }
    }

    function stream()
        internal
        view
        virtual
        onlyFinalized
        returns (string memory base64Stream)
    {
        bytes memory fullData = assemble();
        base64Stream = OnChainCodec.encodeWithMime(info.mimeType, fullData);
    }
}
