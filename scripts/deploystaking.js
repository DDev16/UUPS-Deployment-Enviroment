const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying StakingContract with account:", deployer.address);

  // Define the addresses for the rewardsToken (ERC20) and the nftCollection (ERC721)
  const rewardsTokenAddress = "0xa27bC320252d51EEAA24BCCF6cc003979E485860"; // Replace with the actual ERC20 token address
  const nftCollectionAddress = "0xa27bC320252d51EEAA24BCCF6cc003979E485860"; // Replace with the actual ERC721 token address
  const initialOwner = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30"; // Replace with the initial owner address

  // Deploy the StakingContract with the rewardsTokenAddress and nftCollectionAddress
  const StakingContract = await hre.ethers.getContractFactory("ChaoticCreationsStaking");
  const stakingContract = await StakingContract.deploy();
  await stakingContract.waitForDeployment();

  // Initialize the contract with the specified addresses
  await stakingContract.initialize(rewardsTokenAddress, nftCollectionAddress, initialOwner);

  console.log("StakingContract deployed to:", stakingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
