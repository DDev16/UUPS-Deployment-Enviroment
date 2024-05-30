const axios = require('axios');
const fs = require('fs');

const API_URL = "https://songbird-explorer.flare.network/api";
const contractAddress = "0x02f0826ef6aD107Cfc861152B32B52fD11BaB9ED";
let allHolders = [];

async function fetchTokenHoldersPage(page = 1, offset = 1000) { // Adjust offset as needed
    console.log(`Fetching page ${page}...`);
    try {
        const response = await axios.get(`${API_URL}?module=token&action=getTokenHolders&contractaddress=${contractAddress}&page=${page}&offset=${offset}`);
        if (response.data && response.data.status === "1" && response.data.result.length > 0) {
            allHolders = allHolders.concat(response.data.result);
            console.log(`Page ${page} fetched. Total holders so far: ${allHolders.length}`);
            
            // Check if the current page might not be the last one
            if (response.data.result.length === offset) {
                // There might be more pages
                await fetchTokenHoldersPage(page + 1, offset);
            } else {
                // Last page reached
                console.log("Last page reached or fewer items than offset.");
            }
        } else {
            console.log("No more data or error fetching data.");
        }
    } catch (error) {
        console.error(`Error fetching page ${page}: ${error}`);
    }
}

async function saveTokenHolders() {
    await fetchTokenHoldersPage(); // Start fetching from the first page
    fs.writeFile('tokenHolders.json', JSON.stringify(allHolders, null, 2), err => {
        if (err) {
            console.error("Error writing file:", err);
        } else {
            console.log(`Token holders saved to tokenHolders.json, total holders fetched: ${allHolders.length}`);
        }
    });
}

saveTokenHolders().catch(console.error);
