const fs = require("fs");
const path = require("path");
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);

  const filePath = path.join(__dirname, "../icon.png");
  const buffer = fs.readFileSync(filePath);
  const rawBytes = Uint8Array.from(buffer);
  console.log(buffer);
  console.log(rawBytes);
}

main().catch((err) => {
  console.error("💥 Error:", err);
  process.exit(1);
});
