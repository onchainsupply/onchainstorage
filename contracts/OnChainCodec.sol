// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

library OnChainCodec {
    function decode(bytes memory data) internal pure returns (string memory) {
        return string(abi.encodePacked("data:application/octet-stream;base64,", Base64.encode(data)));
    }

    function hash(bytes memory data) internal pure returns (bytes32) {
        return keccak256(data);
    }
}
