// Import necessary modules
const axios = require('axios');
const fs = require('fs');

// Configuration
const apiUrl = 'https://flare-explorer.flare.network/api';
const contractAddress = '0x1D80c49BbBCd1C0911346656B529DF9E5c2F783d';
const pageSize = 1000;  // Adjust page size as needed
const airdropAmount = "397177";  // Airdrop amount for each recipient

async function getTokenHolders() {
    let page = 1;
    let hasMore = true;
    let airdropData = [];

    console.log(`Starting to fetch token holders for contract: ${contractAddress}`);

    while (hasMore) {
        console.log(`Fetching page ${page}...`);
        try {
            const response = await axios.get(`${apiUrl}?module=token&action=getTokenHolders&contractaddress=${contractAddress}&page=${page}&offset=${pageSize}`);
            const data = response.data.result;

            if (data && data.length > 0) {
                console.log(`Page ${page}: Retrieved ${data.length} token holders`);
                // Create an airdrop entry for each address
                const recipients = data.map(holder => ({
                    recipient: holder.address,
                    amount: airdropAmount
                }));
                airdropData.push(...recipients);
                page++;
            } else {
                console.log('No more data to fetch, ending pagination.');
                hasMore = false;
            }
        } catch (error) {
            console.error(`An error occurred while fetching page ${page}: ${error}`);
            hasMore = false;  // Stop loop on error
        }
    }

    // Save the data to a JSON file
    fs.writeFileSync('airdropRecipients.json', JSON.stringify(airdropData, null, 2));
    console.log('Airdrop recipient data has been saved to airdropRecipients.json');
}

// Run the function
getTokenHolders().catch(err => {
    console.error("Failed to fetch token holders:", err.message);
});
