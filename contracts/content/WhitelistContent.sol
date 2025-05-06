// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title WhitelistContent
/// @notice Content restricted to a whitelist of allowed addresses
contract WhitelistContent is OnChainStorage {
    uint256 public usageCount;
    mapping(address => bool) public whitelist;

    constructor(
        bytes memory chunk,
        address _owner,
        bool _finalized
    ) OnChainStorage(chunk, _owner, _finalized) {}

    function addToWhitelist(address user) external onlyOwner {
        whitelist[user] = true;
    }

    function removeFromWhitelist(address user) external onlyOwner {
        whitelist[user] = false;
    }

    function use() external returns (bool) {
        require(whitelist[msg.sender], "Not whitelisted");
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(whitelist[msg.sender], "Access denied");
    }
}
