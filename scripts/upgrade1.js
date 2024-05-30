const { ethers, upgrades } = require("hardhat");

async function main() {
  const proxyAddress = '0x09635F643e140090A9A8Dcd712eD6285858ceBef'; // Existing UUPS proxy address
  const TruckingEmpireFractionalNFTs = await ethers.getContractFactory("FlareBears");

  console.log("Preparing upgrade...");

  try {
    console.log("Importing proxy for upgrades...");
    // Use forceImport to manually register the proxy
    await upgrades.forceImport(proxyAddress, TruckingEmpireFractionalNFTs);
    
    console.log("Proxy imported successfully, attempting upgrade...");

    const upgradedProxy = await upgrades.upgradeProxy(proxyAddress, TruckingEmpireFractionalNFTs);
    console.log("Proxy Contract deployed to:", await upgradedProxy.getAddress());
  } 
  
  catch (error) {
    console.error("Upgrade failed. Error details:");
    console.error(error);

    if (error.data) {
      // If there's additional error data, you can log it as well.
      console.error("Error data:", error.data);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Script execution failed. Error details:");
    console.error(error);
    process.exit(1);
  });
