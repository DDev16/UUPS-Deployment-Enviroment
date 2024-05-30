const hre = require("hardhat");

async function main() {
    // Deploying the CustomizableERC20 contract
    const CustomizableERC20 = await hre.ethers.getContractFactory("AirdropContractTest");
    const initialOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // replace this with the actual initial owner address
    const customizableERC20 = await CustomizableERC20.deploy(initialOwner);
    await customizableERC20.waitForDeployment();  // Wait for the deployment to complete

    console.log("CustomizableERC20 deployed to:", await customizableERC20.getAddress());  // Use getAddress() to retrieve the contract address

    // // Deploying the PreSale contract
    // const PreSale = await hre.ethers.getContractFactory("PreSale");
    // const preSale = await PreSale.deploy(customizableERC20.address);
    // await preSale.waitForDeployment();  // Wait for the deployment to complete

    // console.log("PreSale deployed to:", await preSale.getAddress());  // Use getAddress() to retrieve the contract address
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
