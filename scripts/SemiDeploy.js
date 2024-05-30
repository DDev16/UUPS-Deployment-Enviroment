const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying Trucking Empire ERC20 tokens with account:",
    deployer.address
  );

  const initialOwner = "0x8145E572eD429e4cb38150C754C9c61Fd7CE21E6";

  try {
    const ERC202 = await ethers.getContractFactory("SEMI");

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
