const { ethers } = require("ethers");
const fs = require("fs");

// Load the addresses from the JSON file
const tokenHolders = JSON.parse(fs.readFileSync("tokenHolders.json", "utf8"));
const BATCH_SIZE = 100;

// Flare Coston testnet provider
const provider = new ethers.providers.JsonRpcProvider("https://coston-api.flare.network/ext/bc/C/rpc");

// Wallet private key (ensure you replace this with the actual private key)
const privateKey = "3f9915e8bc5a3d035fdccd81204e043fd9e64a059b83bf48f11988b307c7f046";
const wallet = new ethers.Wallet(privateKey, provider);

// Smart contract ABI and address (replace with your contract's ABI and address)
const contractAbi = [ /* Your Contract ABI */ ];
const contractAddress = "0x819f7E0eF35ec1f6C9F00087ae3fc09dEC9C2Ba7";
const contract = new ethers.Contract(contractAddress, contractAbi, wallet);

// Airdrop function
async function airdropTokens() {
  try {
    for (let i = 0; i < tokenHolders.length; i += BATCH_SIZE) {
      const batch = tokenHolders.slice(i, i + BATCH_SIZE);
      const tx = await contract.batchAirdrop(batch, { gasLimit: 5000000 });
      console.log(`Airdrop batch ${i / BATCH_SIZE + 1} sent:`, tx.hash);
      await tx.wait();
    }
    console.log("Airdrop completed successfully.");
  } catch (error) {
    console.error("Airdrop failed:", error);
  }
}

// Execute the airdrop
airdropTokens();
