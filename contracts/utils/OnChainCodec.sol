// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/// @title ONCHAINSUPPLY:CODEC
/// @notice Utility library to encode bytes as base64 data URIs
library OnChainCodec {
    /// @notice Encodes raw bytes into a data URI as application/octet-stream
    /// @dev RFC 2397-compliant
    /// @param data Raw byte data to encode
    /// @return uri Complete data URI string
    function encodeOctetStream(
        bytes memory data
    ) internal pure returns (string memory uri) {
        uri = string(
            abi.encodePacked(
                "data:application/octet-stream;base64,",
                Base64.encode(data)
            )
        );
    }

    /// @notice Encodes raw bytes into a data URI as image/svg+xml
    /// @param svg SVG string data to encode
    /// @return uri Base64 encoded data URI string
    function encodeSVG(
        string memory svg
    ) internal pure returns (string memory uri) {
        uri = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(svg))
            )
        );
    }

    /// @notice Encodes JSON object string as application/json data URI
    /// @param json JSON string to encode
    /// @return uri Base64 encoded data URI string
    function encodeJSON(
        string memory json
    ) internal pure returns (string memory uri) {
        uri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(json))
            )
        );
    }

    /// @notice Encodes HTML content as text/html data URI
    /// @param html Raw HTML string
    /// @return uri Base64 encoded data URI
    function encodeHTML(
        string memory html
    ) internal pure returns (string memory uri) {
        uri = string(
            abi.encodePacked(
                "data:text/html;base64,",
                Base64.encode(bytes(html))
            )
        );
    }

    /// @notice Encodes plain text as text/plain data URI
    /// @param text Raw text string
    /// @return uri Base64 encoded data URI
    function encodeText(
        string memory text
    ) internal pure returns (string memory uri) {
        uri = string(
            abi.encodePacked(
                "data:text/plain;base64,",
                Base64.encode(bytes(text))
            )
        );
    }
}
