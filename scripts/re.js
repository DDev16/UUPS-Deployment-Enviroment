// scripts/deploy.js

async function main() {
    // We get the contract to deploy
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");
    const realEstateToken = await RealEstateToken.deploy();

    await realEstateToken.deployed();

    console.log("RealEstateToken deployed to:", realEstateToken.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
