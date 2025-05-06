// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IOnChainStorage} from "../interfaces/IOnChainStorage.sol";
import {OnChainStorage} from "../OnChainStorage.sol";

/// @title BasicContent
/// @notice Open-access content with no usage limits or fees
contract BasicContent is OnChainStorage {
    uint256 public usageCount;

    constructor(
        bytes memory chunk,
        address _owner,
        bool _finalized
    ) OnChainStorage(chunk, _owner, _finalized) {}

    /// @notice Register content use (unrestricted)
    function use() external returns (bool) {
        usageCount++;
        return true;
    }
}
