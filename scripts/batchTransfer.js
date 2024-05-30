// Import required modules
const { ethers } = require("hardhat");
const tokenHolders = require("../json/tokenHolders.json"); // Make sure the path is correct

async function main() {
    // The ID of the NFT to distribute
    const tokenId = 20;
    // The amount of the NFT to send to each address
    const amount = 1;
    // Data is empty, as it's not needed for this transfer
    const data = "0x";

    // Deployer's address will be used to send the NFTs
    // Assuming the deployer's address currently owns the NFTs
    const [deployer] = await ethers.getSigners();

    // The contract address of your ERC1155 NFT
    const contractAddress = "0xf94947D37ddcC003279654E4C6eaBFdCD2EFE3Ae";
    // Connect to your deployed ERC1155 contract
    const contract = await ethers.getContractAt("MarketingTesting", contractAddress, deployer);

    // Iterate over the tokenHolders array to transfer NFTs
    for (const holder of tokenHolders) {
        const recipientAddress = holder.address;
        try {
            console.log(`Transferring NFT with ID ${tokenId} to ${recipientAddress}`);
            await contract.safeTransferFrom(deployer.address, recipientAddress, tokenId, amount, data);
        } catch (error) {
            console.log(`Failed to transfer NFT to ${recipientAddress}: ${error.message}`);
        }
    }
    
    console.log("All NFTs have been transferred.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
