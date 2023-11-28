async function main() {
  const proxyAddress = '0x07e03502bf3A5851E9235aebc2D86612123F7236'; // Existing UUPS proxy address
  const BoxV2 = await ethers.getContractFactory("NFTV2");

  console.log("Preparing upgrade...");

  try {
    const upgradedProxy = await upgrades.upgradeProxy(proxyAddress, BoxV2);
    console.log("Upgrade successful. New proxy address:", upgradedProxy.address);
    console.log("Upgrade proxy address same as initial:", proxyAddress);

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
