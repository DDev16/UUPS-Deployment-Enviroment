async function main() {
  const proxyAddress = '0xa27bC320252d51EEAA24BCCF6cc003979E485860'; // Existing UUPS proxy address
  const BoxV2 = await ethers.getContractFactory("Chibifactory1");

  console.log("Preparing upgrade...");

  try {
    const upgradedProxy = await upgrades.upgradeProxy(proxyAddress, BoxV2);
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
