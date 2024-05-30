const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying FlareBear ERC20 tokens with account:",
    deployer.address
  );

  // const initialOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  // const initialOwner = "0x8145E572eD429e4cb38150C754C9c61Fd7CE21E6";
  const initialOwner = "0x908202958E91AFCD18DFd6Bac7551ED889188981"; //CHib
  const rewardsWallet = "0x3926A4fe7c322A0Dc51AEcFB93ff2E0181724f26"; //CHib

  try {
    const ERC202 = await ethers.getContractFactory("TestBonko21");

    const FlareBear = await upgrades.deployProxy(ERC202, [initialOwner, rewardsWallet], {
      initializer: "initialize",
      kind: "uups",
    });

    await FlareBear.waitForDeployment();

    console.log("Flare Bear deployed to:", await FlareBear.getAddress());
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
