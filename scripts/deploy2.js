const { ethers, upgrades } = require("hardhat");

async function main() {
    // const customTokenAddress = "0xCAb7Cf9AA9aFD7E3d3B0c70F302454fc09D68dC6";
    const initialOwner = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

    const ChibiFactory = await ethers.getContractFactory("RealEstateToken");
    const chibiFactory = await upgrades.deployProxy(ChibiFactory, [initialOwner], { kind: 'uups' });

    await chibiFactory.waitForDeployment();

    console.log(" ERC1155 deployed to:", await chibiFactory.getAddress());
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
