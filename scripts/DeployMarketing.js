// Import ethers and upgrades tool from Hardhat
const { ethers, upgrades } = require("hardhat");

async function main() {
  try {
    // Get the contract factory for NirvanisMarketing
    const NirvanisMarketing = await ethers.getContractFactory("MarketingTesting");

    // Deploy the contract as a UUPS upgradeable proxy
    // The second parameter in deployProxy is an array of arguments for the initialize function
    // Assuming "0x2546BcD3c84621e976D8185a91A922aE77ECEc30" is the initialOwner address parameter for your initialize function
    console.log("Deploying marketing proxy contract for Test...");
    const nirvanisMarketing = await upgrades.deployProxy(NirvanisMarketing, ["testingmarketing","0x908202958E91AFCD18DFd6Bac7551ED889188981"], { kind: 'uups' });

    // The deployment is asynchronous, use 'deployed()' to wait for it to finish
    await nirvanisMarketing.waitForDeployment();
    console.log("Marketing deployed to:", await nirvanisMarketing.getAddress());

  } catch (error) {
    console.error("Error in deployment:", error);
  }
}

// Run the main function and catch any errors
main().catch((error) => {
  console.error("Error in script:", error);
  process.exitCode = 1;
});
