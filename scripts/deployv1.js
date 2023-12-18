const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    // Deploying the initial contract
    const Box = await ethers.getContractFactory("NFTV1");

    const box = await upgrades.deployProxy(Box, ["0x2546BcD3c84621e976D8185a91A922aE77ECEc30"], { kind: 'uups' });
    console.log("Deploying proxy contract for Test");

    await box.waitForDeployment();
    console.log("Box deployed to:", await box.getAddress());


  } catch (error) {
    console.error("Error:", error);
  }
}

main();
