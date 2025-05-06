// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title PayPerUseContent
/// @notice Content requiring payment for each use
contract PayPerUseContent is OnChainStorage {
    uint256 public usageCount;
    uint256 public payment;

    constructor(bytes memory chunk, uint256 _payment, address _owner, bool _finalized)
        OnChainStorage(chunk, _owner, _finalized)
    {
        payment = _payment;
    }

    function use() external payable returns (bool) {
        require(msg.value >= payment, "Insufficient payment");
        usageCount++;
        return true;
    }

    function authorizeViewer() internal view override {
        require(msg.value >= payment, "Payment required to view");
    }
}
