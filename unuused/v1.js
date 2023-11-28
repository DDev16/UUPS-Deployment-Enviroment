const { ethers, upgrades } = require("hardhat");

describe("NFTV1 Deployment Test", function () {
  let Box;

  before(async () => {
    // Deploy the initial contract
    Box = await ethers.getContractFactory("NFTV2");
  });

  it("Should deploy NFTV1 contract", async function () {
    const box = await upgrades.deployProxy(Box, ["0x2546BcD3c84621e976D8185a91A922aE77ECEc30"], { kind: 'uups' });
    await box.waitForDeployment();

    console.log("Box deployed to:", await box.getAddress());
    // You can add more assertions or tests here if needed
  });
});
