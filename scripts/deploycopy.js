const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying Trucking Empire ERC20 tokens with account:",
    deployer.address
  );

  const initialOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  try {
    const ERC202 = await ethers.getContractFactory("SwapContractNative");

    const TruckingToken2 = await upgrades.deployProxy(ERC202, [initialOwner], {
      initializer: "initialize",
      kind: "uups",
    });

    await TruckingToken2.waitForDeployment();

    console.log("SEMI deployed to:", await TruckingToken2.getAddress());
  } catch (error) {
    console.error("Error:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
