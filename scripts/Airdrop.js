const fs = require("fs");
const { ethers } = require("ethers");
require("dotenv").config();

const provider = new ethers.providers.JsonRpcProvider("https://coston-api.flare.network/ext/C/rpc");
const wallet = new ethers.Wallet(process.env.REACT_APP_SECRET_KEY, provider);

async function sendTransaction(contract, to, amount) {
    if (!ethers.utils.isAddress(to)) {
        console.error(`Invalid address: ${to}`);
        return false;  // Skip invalid addresses
    }

    const options = { gasLimit: 1000000 }; // Start with a high gas limit
    try {
        const tx = await contract.transfer(to, amount, options);
        await tx.wait();
        console.log(`Transfer complete for ${to}`);
        return true;
    } catch (error) {
        console.error(`Transfer failed for ${to}: ${error.message}`);
        if (error.message.toLowerCase().includes('gas')) {
            // Retry with a higher gas limit if it's a gas-related error
            options.gasLimit = 1500000; // Increase gas limit
            try {
                const retryTx = await contract.transfer(to, amount, options);
                await retryTx.wait();
                console.log(`Transfer complete after retry for ${to}`);
                return true;
            } catch (retryError) {
                console.error(`Retry transfer failed for ${to}: ${retryError.message}`);
                return false;
            }
        }
        return false; // Return failure if non-gas related error
    }
}

async function batchTransactions() {
    const data = fs.readFileSync("tokenHolders.json", "utf8");
    const tokenHolders = JSON.parse(data);
    const tokenContract = new ethers.Contract(
        "0x56eC74fa0f0f16E6aeF6F8E5138c4D2765B8ACDd",
        ["function transfer(address to, uint256 amount) returns (bool)"],
        wallet
    );

    const tokenAmount = ethers.utils.parseUnits("1", 18); // Adjust token amount if needed
    const failedAddresses = [];

    for (const holder of tokenHolders) {
        console.log(`Attempting transfer to ${holder.address}`);
        const success = await sendTransaction(tokenContract, holder.address, tokenAmount);
        if (!success) failedAddresses.push(holder.address);
        await new Promise(resolve => setTimeout(resolve, 1000 / 30)); // Control the rate of transactions
    }

    if (failedAddresses.length > 0) {
        console.log("Failed transfers:", failedAddresses);
        fs.writeFileSync("failedTransfers.json", JSON.stringify(failedAddresses, null, 2));
    }
}

batchTransactions()
    .then(() => console.log("All transfers done."))
    .catch(error => console.error("Error during batch transactions:", error));
