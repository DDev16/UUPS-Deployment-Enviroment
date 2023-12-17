const { ethers, upgrades } = require("hardhat");

async function main() {
    console.log("Getting the contract factory for NFTV1...");
    const NFTV1 = await ethers.getContractFactory("NFTV1");
    console.log("NFTV1 contract factory obtained.");

    const initialOwner = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30"; // Replace with the initial owner address
    const psychoGemsTokenAddress = "0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82"; // Psycho Gems Token Address

    console.log("Starting the deployment of the NFTV1 contract...");
    try {
        const nftV1 = await upgrades.deployProxy(NFTV1, [initialOwner, psychoGemsTokenAddress], { kind: 'uups' });
        await nftV1.waitForDeployment();
        console.log("NFTV1 contract deployed successfully.");
console.log(nftV1);

// Directly log the contract address



        if (nftV1.address) {
            console.log(`NFTV1 deployed to: ${nftV1.target}`);
        } else {
            console.error("Deployment successful but unable to fetch deployed contract address.");
        }
    } catch (error) {
        console.error("Error during NFTV1 contract deployment:", error);
        process.exitCode = 1;
    }
}

main().catch((error) => {
    console.error("Deployment script encountered an error:", error);
    process.exitCode = 1;
});
