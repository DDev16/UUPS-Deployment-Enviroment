const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying StakingContract with account:", deployer.address);

  // Define and assign an initial owner's Ethereum address
  const initialOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  // Deploy the StakingContract with the initialOwner address
  const StakingContract = await hre.ethers.getContractFactory("StakingContract");
  const stakingContract = await StakingContract.deploy("0x851356ae760d987E095750cCeb3bC6014560891C", initialOwner);

  await stakingContract.waitForDeployment();

  console.log("StakingContract deployed to:", stakingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
