// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title CappedContent
/// @notice Content with a maximum number of uses allowed
contract CappedContent is OnChainStorage {
    uint256 public usageCount;
    uint256 public maxUsage;

    constructor(bytes memory chunk, uint256 _maxUsage, address _owner, bool _finalized)
        OnChainStorage(chunk, _owner, _finalized)
    {
        maxUsage = _maxUsage;
    }

    function use() external returns (bool) {
        require(usageCount < maxUsage, "Max use reached");
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(usageCount < maxUsage, "Max access reached");
    }
}
