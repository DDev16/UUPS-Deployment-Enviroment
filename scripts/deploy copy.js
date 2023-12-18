const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying StakingContract with account:", deployer.address);

  // Define the addresses for the rewardsToken (ERC20) and the nftCollection (ERC721)
  const rewardsTokenAddress = "0xa27bC320252d51EEAA24BCCF6cc003979E485860";
  const nftCollectionAddress = "0xfBECbd548B8BdA886BA45cA496C89C9227a51d4F";
  const initialOwner = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30";

  try {
    // Deploying the initial ERC20 contract
    const ERC20 = await ethers.getContractFactory("ERC20V1");
    const PsychoGems = await upgrades.deployProxy(ERC20, [initialOwner], { initializer: 'initialize', kind: 'uups' });
    
    // Deploying the initial ERC721 contract
    const ERC721 = await ethers.getContractFactory("NFTV1");
    const PsychoChibis = await upgrades.deployProxy(ERC721, [initialOwner], { initializer: 'initialize', kind: 'uups' });

    // Deploy the StakingContract as a UUPS upgradeable contract
    const StakingContract = await ethers.getContractFactory("ChaoticCreationsStaking");
    const stakingContract = await upgrades.deployProxy(StakingContract, [rewardsTokenAddress, nftCollectionAddress, initialOwner], { initializer: 'initialize', kind: 'uups' });

    // Wait for deployment completion
    await PsychoGems.waitForDeployment();
    await PsychoChibis.waitForDeployment();
    await stakingContract.waitForDeployment();

    // Log deployed addresses
    console.log("Psycho Gems deployed to:", await PsychoGems.getAddress());
    console.log("Psycho Chibis deployed to:", await PsychoChibis.getAddress());
    console.log("StakingContract deployed to:", await stakingContract.getAddress());

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
