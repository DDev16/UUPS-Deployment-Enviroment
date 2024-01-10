const { ethers, upgrades } = require("hardhat");

async function main() {
    const customTokenAddress = "0xa27bC320252d51EEAA24BCCF6cc003979E485860";
   

    const ChibiFactory = await ethers.getContractFactory("Chibifactory1");
    const chibiFactory = await upgrades.deployProxy(ChibiFactory, [customTokenAddress], { kind: 'uups' });

    await chibiFactory.waitForDeployment();

    console.log("Chibi-Factory deployed to:", await chibiFactory.getAddress());
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
