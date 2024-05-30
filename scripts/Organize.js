const fs = require('fs');
const path = require('path');

// Load the token holders from the JSON file
const tokenHolders = require('./tokenHolders.json');

const batchSize = 100; // Number of addresses per batch
const totalBatches = Math.ceil(tokenHolders.length / batchSize);
const batchDir = path.join(__dirname, 'batchAirdropList');

// Create the batchAirdropList directory if it doesn't exist
if (!fs.existsSync(batchDir)) {
    fs.mkdirSync(batchDir);
}

for (let i = 0; i < totalBatches; i++) {
    const batch = tokenHolders.slice(i * batchSize, (i + 1) * batchSize);
    const batchFileName = path.join(batchDir, `batch_${i + 1}.json`);

    fs.writeFileSync(batchFileName, JSON.stringify(batch, null, 2));
    console.log(`Batch ${i + 1} written to ${batchFileName}`);
}

console.log(`Total batches created: ${totalBatches}`);
