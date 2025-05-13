# @onchainsupply/storage

A Solidity-based library for decentralized, extensible, and programmable content storage. Designed for projects that want to go **fully onchain** with human-readable, media-rich assets that are composable, tokenizable, and monetizable.

## 🌐 Overview

`@onchainsupply/storage` provides:

- Modular, gas-efficient smart contracts to store and stream onchain files in chunks
- Access models (open, capped, pay-per-use, whitelist, and combined models)
- RFC 2397-compliant base64 streaming via `OnChainCodec`
- Extensible base contract `OnChainStorage`

## 📦 Install

```bash
npm install @onchainsupply/storage
```

## 🏗 Contracts

### 🔹 OnChainStorage (Abstract)

The core contract used for storing finalized, chunked byte streams onchain.

```solidity
function extend(bytes[] calldata data) external onlyOwner;
function finalize() external onlyOwner;
function purge() external onlyOwner;
function assemble() internal view returns (bytes memory);
function stream() internal view returns (string memory);
```

Use this for building advanced content logic.

### 🔸 Content Types

Each of these extends `OnChainStorage` and implements a usage/access model.

| Contract                  | Description                                      |
| ------------------------- | ------------------------------------------------ |
| `BasicContent`           | Unlimited use, public view access                |
| `CappedContent`          | Use limited by `maxUsage`                        |
| `PayPerUseContent`       | Requires ETH payment per access                  |
| `WhitelistContent`       | Only approved addresses may use/view             |
| `PayPerUseCappedContent` | Combined payment and usage limit requirements    |

### 🔸 Interface

```solidity
interface IOnChainStorage {
  function chunkCount() external view returns (uint256);
  function chunks(uint256 index) external view returns (bytes memory);
  function finalized() external view returns (bool);
  function assemble() external view returns (bytes memory);
  function stream() external view returns (string memory);
  function info() external view returns (
    string memory name,
    string memory version,
    uint256 createdAt,
    string memory description);
}
```

## 🧰 Codec Library

`OnChainCodec` provides standard base64 encoders for content:

```solidity
OnChainCodec.encodeOctetStream(bytes);
OnChainCodec.encodeSVG(string);
OnChainCodec.encodeJSON(string);
OnChainCodec.encodeHTML(string);
OnChainCodec.encodeText(string);
```

## 🧪 Testing

Test scripts (in `test/store.js`) verify:

- Uploading and assembling chunks
- Finalization logic
- Stream URI formatting
- Gated `use()` behavior for each model
- Combined access control models

## 📄 License

- Core contracts (`OnChainStorage`, `OnChainCodec`) are licensed under **Apache-2.0**
- Content templates (`BasicContent`, `CappedContent`, etc.) are licensed under **MIT**

You may use and extend each component independently according to its license terms.

---

Built with ❤️ by [OnChainSupply](https://onchainsupply.net)
