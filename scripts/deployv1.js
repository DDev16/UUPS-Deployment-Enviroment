const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    // Deploying the initial contract
    const Box = await ethers.getContractFactory("MarketingTesting");

    const box = await upgrades.deployProxy(Box, ["0x908202958E91AFCD18DFd6Bac7551ED889188981"], { kind: 'uups' });
    console.log("Deploying marketing proxy contract for Test");

    await box.waitForDeployment();
    console.log("Marketing deployed to:", await box.getAddress());


  } catch (error) {
    console.error("Error:", error);
  }
}

main();
