const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying All Contracts with account:", deployer.address);

  //Define address for the initial owner

  const initialOwner = "0x908202958E91AFCD18DFd6Bac7551ED889188981";

  try {
    // Deploying the initial ERC20 contract
    const ERC20 = await ethers.getContractFactory("PsychoGems");
    const PsychoGems = await upgrades.deployProxy(ERC20, [initialOwner], { initializer: 'initialize', kind: 'uups' });
    const psychoGemsAddress = await PsychoGems.getAddress();

    // Deploying the initial ERC721 contract
    const ERC721 = await ethers.getContractFactory("SimpleChibifactory");
    const PsychoChibis = await upgrades.deployProxy(ERC721, [ psychoGemsAddress ], { initializer: 'initialize', kind: 'uups' });
 
    

    // const psychoChibisAddress = await PsychoChibis.getAddress();


    // // Deploy the StakingContract as a UUPS upgradeable contract
    // const StakingContract = await ethers.getContractFactory("ChaoticCreationsStaking");
    // const stakingContract = await upgrades.deployProxy(StakingContract, [psychoGemsAddress, psychoChibisAddress, initialOwner], { initializer: 'initialize', kind: 'uups' });

    // Wait for deployment completion
    await PsychoGems.waitForDeployment();
    await PsychoChibis.waitForDeployment();
    // await stakingContract.waitForDeployment();

    // Log deployed addresses
    console.log("Psycho Gems deployed to:", await PsychoGems.getAddress());
    console.log("Psycho Simple Factory deployed to:", await PsychoChibis.getAddress());
    // console.log("StakingContract deployed to:", await stakingContract.getAddress());


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
