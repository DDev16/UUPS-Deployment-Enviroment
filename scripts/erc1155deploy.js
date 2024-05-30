const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying ERC1155Staking Contract with account:", deployer.address);

  //Define address for the initial owner
  const RewardsToken = "0xCAb7Cf9AA9aFD7E3d3B0c70F302454fc09D68dC6";
  const NFTokenAddress = "0x97aDa9893e43C9CE7f8A69EA41b872778Eb4dD16";
  const initialOwner = "0x8145E572eD429e4cb38150C754C9c61Fd7CE21E6";
  const rewardRate = 100;
  try {
    // Deploying the initial ERC20 contract
    const ERC20 = await ethers.getContractFactory("EnhancedSoftStakingContract");
    const PsychoGems = await upgrades.deployProxy(ERC20, [initialOwner, RewardsToken, NFTokenAddress, rewardRate ], { initializer: 'initialize', kind: 'uups' });

    

    // Wait for deployment completion
    await PsychoGems.waitForDeployment();


    // Log deployed addresses
    console.log("ERC1155 Staking deployed to:", await PsychoGems.getAddress());
 

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
