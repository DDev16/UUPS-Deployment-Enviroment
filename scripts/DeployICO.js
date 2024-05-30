const hre = require("hardhat");

async function main() {
    // We get the contract to deploy
    const FlareBearICO = await hre.ethers.getContractFactory("FlareBearICO");

    // Here, you need to pass the token contract address and the initial owner address
    const tokenContractAddress = "0x5c948681C1c9c4d84BAf93A0CdBd16B6b188eBBb";
    const initialOwnerAddress = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30";

    const flareBearICO = await FlareBearICO.deploy(tokenContractAddress, initialOwnerAddress);

  

    console.log("FlareBearICO deployed to:", flareBearICO.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
