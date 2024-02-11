function calculateTotalCombinations(optionsList) {
    const categoryCounts = optionsList.map(options => options.length);

    const product = categoryCounts.reduce((total, count) => total * count, 1);
    
    // Factor in supply values
    const combinationsWithSupply = optionsList.reduce((total, options) => {
        const usedIndices = new Set();
        let categoryCombinations = 0;
        
        for (let i = 0; i < options.length; i++) {
            if (!usedIndices.has(i)) {
                categoryCombinations += options[i].supply;
                usedIndices.add(i);
            }
        }
        
        return total * categoryCombinations;
    }, 1);

    return Math.min(product, combinationsWithSupply);
}

// Hat Options
const hatOptions = [
    { name: "kitty", supply: 10, price: 1000 },
    { name: "SGB beanie", supply: 28, price: 2 },
    { name: "toad", supply: 15, price: 800 },
    { name: "spinny cap", supply: 30, price: 4 },
    { name: "mohawk", supply: 40, price: 5 },
    { name: "samaraui", supply: 30, price: 6 },
    { name: "alien antennaas", supply: 20, price: 7 },
    { name: "astronuaght Helmet", supply: 40, price: 8 },
    { name: "black Hair", supply: 50, price: 9 },
    { name: "clown Hat", supply: 35, price: 1 },
    { name: "construction Hat", supply: 45, price: 2 },
    { name: "devil Horns", supply: 10, price: 3 },
    { name: "firefighter Helmet", supply: 50, price: 4 },
    { name: "golden Poo", supply: 5, price: 5 },
    { name: "grey SGB Beanie", supply: 6, price: 6 },
    { name: "halo", supply: 5, price: 7 },
    { name: "headderess", supply: 4, price: 8 },
    { name: "headphones", supply: 3, price: 9 },
    { name: "hippy Bucket Hat", supply: 2, price: 1 },
    { name: "kings Crown", supply: 1, price: 2 },
    { name: "NFT Cap", supply: 6, price: 3 },
    { name: "NFT Songbird Beanie", supply: 5, price: 4 },
];

// Accessory Options
const accessoryOptions = [
    { name: "Bandana", supply: 5, price: 15 },
    { name: "EyePatch", supply: 40, price: 25 },
    { name: "Flare Tattoo", supply: 3, price: 35 },
    { name: "LolliPop", supply: 2, price: 45 },
    { name: "PsychoFlower", supply: 1, price: 55 },
    { name: "PsychoGemStaff", supply: 1, price: 15 },
    { name: "PsychoGem", supply: 4, price: 25 },
];

// Head Options
const headOptions = [
    { name: "original Head", supply: 6, price: 2 },
    { name: "green Alien Head", supply: 5, price: 3 },
    { name: "humanoid Head", supply: 4, price: 4 },
    { name: "robot Head", supply: 3, price: 5 },
    { name: "alien Head", supply: 2, price: 6 },
    { name: "gold Head", supply: 1, price: 7 },
    { name: "monkey", supply: 6, price: 8 },
    { name: "blue Head", supply: 5, price: 9 },
    { name: "green Head", supply: 4, price: 2 },
    { name: "red Head", supply: 3, price: 3 },
    { name: "skull", supply: 2, price: 4 },
    { name: "zombie Head", supply: 1, price: 5 },
];

// Mouth Options
const mouthOptions = [
    { name: "vampire mouth", supply: 3, price: 3 },
    { name: "butter", supply: 2, price: 4 },
    { name: "big smile", supply: 1, price: 5 },
    { name: "happy", supply: 3, price: 3 },
    { name: "pearly teeth", supply: 2, price: 4 },
    { name: "smile", supply: 1, price: 5 },
    { name: "smiley tongue", supply: 3, price: 3 },
    { name: "tobacco pipe", supply: 2, price: 4 },
    { name: "tongueout", supply: 1, price: 5 },
];

// Eye Color Options
const eyeColorOptions = [
    { name: "hypnotize Eyes", supply: 4, price: 25 },
    { name: "rainbowSpiral Eyes", supply: 3, price: 35 },
    { name: "double Eyes", supply: 2, price: 45 },
    { name: "yellow Eyes", supply: 1, price: 55 },
    { name: "black Eyes", supply: 4, price: 25 },
    { name: "blue Spirals", supply: 3, price: 35 },
    { name: "gold Eyes", supply: 2, price: 45 },
    { name: "green Spirals", supply: 1, price: 55 },
    { name: "white Eyes", supply: 4, price: 25 },
    { name: "yellow Spirals", supply: 3, price: 35 },
];

// Body Options
const bodyOptions = [
    { name: "robot Body", supply: 7, price: 18 },
    { name: "original Body", supply: 6, price: 28 },
    { name: "green Body", supply: 5, price: 38 },
    { name: "gold Tuxedo", supply: 40, price: 48 },
    { name: "old 1800s Outfit", supply: 3, price: 58 },
    { name: "alien Hoodie", supply: 2, price: 68 },
    { name: "blue Body", supply: 1, price: 78 },
    { name: "chefs Coat", supply: 7, price: 18 },
    { name: "clown Outfit", supply: 6, price: 28 },
    { name: "construction Outfit", supply: 5, price: 38 },
    { name: "fireFighter", supply: 4, price: 48 },
    { name: "green Body", supply: 3, price: 58 },
    { name: "grey Body", supply: 2, price: 68 },
    { name: "monkey Torso", supply: 1, price: 78 },
    { name: "native Outfit", supply: 7, price: 18 },
    { name: "peace Sign Army Guy", supply: 6, price: 28 },
    { name: "police Uniform", supply: 5, price: 38 },
    { name: "princess Dress", supply: 4, price: 48 },
    { name: "prison Jumpsuit", supply: 3, price: 58 },
    { name: "psycho Chibi", supply: 2, price: 68 },
];

// Back Options
const backOptions = [
    { name: "AK", supply: 2, price: 35 },
    { name: "Angel Wings", supply: 1, price: 45 },
    { name: "Rocket Launcher", supply: 2, price: 35 },
    { name: "Songbird Slugger", supply: 1, price: 45 },
    { name: "Unicorn AK", supply: 2, price: 35 },
];

// Background Options
const backgroundOptions = [
    { name: "pink Gradientbg", supply: 8, price: 12 },
    { name: "green Gradientbg", supply: 7, price: 22 },
    { name: "blue Gradientbg", supply: 6, price: 32 },
    { name: "yellow Gradientbg", supply: 5, price: 42 },
    { name: "dotted Swirlsbg", supply: 4, price: 52 },
    { name: "foil bg", supply: 3, price: 62 },
    { name: "illusion bg", supply: 2, price: 72 },
    { name: "illusion Spinningbg", supply: 1, price: 82 },
    { name: "orange Gradientbg", supply: 8, price: 12 },
    { name: "purple Wavesbg", supply: 7, price: 22 },
];

const totalCombinations = calculateTotalCombinations([hatOptions, accessoryOptions, headOptions, mouthOptions, eyeColorOptions, bodyOptions, backOptions, backgroundOptions]);

console.log("Total Possible Combinations (Unique NFTs with one trait from each category and supply considered):", totalCombinations);

// Check if the total combinations are close to 10,000
if (totalCombinations >= 1000000000000) {
    console.log("Total combinations are sufficient for 10,000 unique NFTs.");
} else {
    console.log("Total combinations are insufficient, adjust supplies accordingly.");
}