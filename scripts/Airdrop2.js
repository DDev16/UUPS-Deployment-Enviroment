require('dotenv').config();
const { ethers } = require('ethers');
const fs = require('fs');

const providerUrl = 'https://rpc.ankr.com/flare';
const privateKey = '0x3f9915e8bc5a3d035fdccd81204e043fd9e64a059b83bf48f11988b307c7f046';
const contractAddress = '0xb29227e3eb2341Efc3549bca9C16a2CcE5e0CDE7';
const tokenHolderPath = './tokenHolders.json';

// Correct usage in ethers v6
const provider = new ethers.providers.JsonRpcProvider(providerUrl);
const wallet = new ethers.Wallet(privateKey, provider);

const airdropAbi = [
    "function batchAirdrop(address[] calldata recipients) public"
];

const airdropContract = new ethers.Contract(contractAddress, airdropAbi, wallet);

const addresses = JSON.parse(fs.readFileSync(tokenHolderPath, 'utf8'));

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function performAirdrop() {
    const batchSize = 100;
    const delayBetweenCalls = 33333;

    for (let i = 0; i < addresses.length; i += batchSize) {
        const batch = addresses.slice(i, i + batchSize);
        try {
            console.log(`Airdropping to addresses ${i} to ${i + batch.length - 1}`);
            const tx = await airdropContract.batchAirdrop(batch);
            await tx.wait();
            console.log('Airdrop successful for this batch');
            if (i + batchSize < addresses.length) {
                await delay(delayBetweenCalls);
            }
        } catch (error) {
            console.error('Failed to airdrop for this batch:', error);
        }
    }
}

performAirdrop();
