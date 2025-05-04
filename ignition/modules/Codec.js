const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Codec", (m) => {
  const codec = m.contract("OnChainCodec");
  return { codec };
});
