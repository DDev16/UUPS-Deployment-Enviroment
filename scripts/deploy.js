const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    // Deploying the initial contract
    const Box = await ethers.getContractFactory("NFTV1");

    const box = await upgrades.deployProxy(Box, ["0x9d1ed4379663b42FF07f36248d4f84FfCCc84251"], { kind: 'uups' });
    console.log("Deploying proxy contract for Test");

    await box.waitForDeployment();
    console.log("Box deployed to:", await box.getAddress());


  } catch (error) {
    console.error("Error:", error);
  }
}

main();
