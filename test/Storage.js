const fs = require("fs");
const path = require("path");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("OnChainStorage using icon.png", function () {
  let owner, user, chunks;
  const CHUNK_SIZE = 24 * 1024; // 24 KB

  before(async () => {
    [owner, user] = await ethers.getSigners();

    const filePath = path.join(__dirname, "../icon.png");
    const fileBuffer = fs.readFileSync(filePath);

    chunks = [];
    for (let i = 0; i < fileBuffer.length; i += CHUNK_SIZE) {
      chunks.push(fileBuffer.slice(i, i + CHUNK_SIZE));
    }
  });

  async function upload(ContentContract, constructorArgs = [], autoFinalize = true) {
    const contract = await ContentContract.deploy(...constructorArgs);
    await contract.waitForDeployment();

    if (chunks.length > 1) {
      const chunkArray = chunks.slice(1).map(c => ethers.getBytes(c));
      await contract.connect(owner).extend(chunkArray);
    }

    if (autoFinalize) {
      await contract.connect(owner).finalize();
    }

    return contract;
  }

  it("BasicContent usage count should increment", async () => {
    const BasicContent = await ethers.getContractFactory("BasicContent");
    const basic = await upload(BasicContent, [chunks[0], owner.address, false]);
    await basic.connect(owner).finalize();

    expect(await basic.chunkCount()).to.equal(chunks.length);
    await basic.connect(user).use();
    expect(await basic.usageCount()).to.equal(1);
  });

  it("CappedContent should respect usage limit", async () => {
    const CappedContent = await ethers.getContractFactory("CappedContent");
    const capped = await upload(CappedContent, [chunks[0], 2, owner.address, false]);
    await capped.connect(owner).finalize();

    await capped.connect(user).use();
    await capped.connect(user).use();
    await expect(capped.connect(user).use()).to.be.revertedWith("Max use reached");
  });

  it("PayPerUseContent should enforce payment", async () => {
    const PayPerUseContent = await ethers.getContractFactory("PayPerUseContent");
    const pay = await upload(PayPerUseContent, [chunks[0], 1, owner.address, false]);
    await pay.connect(owner).finalize();

    await expect(pay.connect(user).use({ value: 0 })).to.be.revertedWith("Insufficient payment");
    await pay.connect(user).use({ value: 1 });
    expect(await pay.usageCount()).to.equal(1);
  });

  it("WhitelistContent should allow only whitelisted users", async () => {
    const WhitelistContent = await ethers.getContractFactory("WhitelistContent");
    const wl = await upload(WhitelistContent, [chunks[0], owner.address, false]);
    await wl.connect(owner).finalize();

    await expect(wl.connect(user).use()).to.be.revertedWith("Not whitelisted");

    await wl.connect(owner).addToWhitelist(user.address);
    await wl.connect(user).use();
    expect(await wl.usageCount()).to.equal(1);
  });
});
