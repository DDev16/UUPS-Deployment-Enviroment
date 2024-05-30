// scripts/deploy_flarebears.js

const hre = require("hardhat");

async function main() {
    const FlareBears = await hre.ethers.getContractFactory("FlareBears");
    const flareBears = await FlareBears.deploy();

    await flareBears.waitForDeployment();

    console.log("FlareBears deployed to:", await flareBears.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
