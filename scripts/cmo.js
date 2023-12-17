const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    // Change these values as needed
    const ownerAddress = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30"; // The address that will deploy the contract

    // Deploying the initial ERC20 contract
    const Box = await ethers.getContractFactory("ERC20V2");
    const box = await upgrades.deployProxy(Box, [ownerAddress], { initializer: "initialize" }, { kind: 'uups' });
    console.log("Deploying proxy contract for Test");
    await box.waitForDeployment();
    console.log("Box deployed to:", await box.getAddress());

    // Deploying the NFT contract with the ERC20V2 address
    const NFTV2 = await ethers.getContractFactory("NFTV2");
    const nftContract = await upgrades.deployProxy(NFTV2, [box.address], { initializer: "initialize" }, { kind: "uups" });
    console.log("Deploying proxy contract for NFTV2");
    await nftContract.deployed();
    console.log("NFT contract deployed to:", await nftContract.address);
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
