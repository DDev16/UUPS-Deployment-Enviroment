const { ethers, upgrades } = require("hardhat");

async function main() {

    const initialOwner = "0x2546BcD3c84621e976D8185a91A922aE77ECEc30";
    // Deploying the initial ERC20 contract
    const ERC20 = await ethers.getContractFactory("PsychoGems");
    const PsychoGems = await upgrades.deployProxy(ERC20, [initialOwner], { initializer: 'initialize', kind: 'uups' });
    const psychoGemsAddress = await PsychoGems.getAddress();


    const ChibiFactory = await ethers.getContractFactory("SimpleChibifactory");
    const chibiFactory = await upgrades.deployProxy(ChibiFactory, [psychoGemsAddress], { kind: 'uups' });


    await PsychoGems.waitForDeployment();
    await chibiFactory.waitForDeployment();

    console.log("Psycho Gems deployed to:", await PsychoGems.getAddress());
    console.log("Chibi-Factory deployed to:", await chibiFactory.getAddress());

    const traitTypeMapping = {
        "Hat": 0,
        "Accessory": 1,
        "Head": 2,
        "Mouth": 3,
        "EyeColor": 4,
        "Body": 5,
        "Back": 6,
        "Background": 7,

    };

    

    // Hat Options
    const hatOptions = [
        { name: "kitty", supply: 10, price: 1 },
        { name: "SGB beanie", supply: 80, price: 2 },
        { name: "toad", supply: 50, price: 3 },
        { name: "spinny cap", supply: 70, price: 4 },
        { name: "mohawk", supply: 40, price: 5 },
        { name: "samaraui", supply: 30, price: 6 },
        { name: "alien antennaas", supply: 20, price: 7 },
        { name: "astronuaght Helmet", supply: 10, price: 8 },
        { name: "black Hair", supply: 60, price: 9 },
        { name: "clown Hat", supply: 50, price: 1 },
        { name: "construction Hat", supply: 40, price: 2 },
        { name: "devil Horns", supply: 30, price: 3 },
        { name: "firefighter Helmet", supply: 20, price: 4 },
        { name: "golden Poo", supply: 5, price: 5 },
        { name: "grey SGB Beanie", supply: 60, price: 6 },
        { name: "halo", supply: 50, price: 7 },
        { name: "headderess", supply: 40, price: 8 },
        { name: "headphones", supply: 30, price: 9 },
        { name: "hippy Bucket Hat", supply: 20, price: 1 },
        { name: "kings Crown", supply: 10, price: 2 },
        { name: "NFT Cap", supply: 60, price: 3 },
        { name: "NFT Songbird Beanie", supply: 50, price: 4 },
        { name: "Pirate Hat", supply: 40, price: 5 },
        { name: "Police Hat", supply: 30, price: 6 },
        { name: "Princess Crown", supply: 20, price: 7 },
        { name: "SGB Top Hat", supply: 10, price: 8 },
        { name: "Sombero", supply: 60, price: 9 },
        { name: "SongBird", supply: 50, price: 1 },
        { name: "Unicorn Horn", supply: 40, price: 2 },
        { name: "Viking Helmet", supply: 30, price: 3 },
    ];

    // Accessory Options
    const accessoryOptions = [
        { name: "Bandana", supply: 50, price: 15 },
        { name: "EyePatch", supply: 40, price: 25 },
        { name: "Flare Tattoo", supply: 30, price: 35 },
        { name: "LolliPop", supply: 20, price: 45 },
        { name: "PsychoFlower", supply: 10, price: 55 },
        { name: "PsychoGemStaff", supply: 10, price: 15 },
        { name: "PsychoGem", supply: 4, price: 25 },

    ];

    // Head Options
    const headOptions = [
        { name: "original Head", supply: 60, price: 2 },
        { name: "green Alien Head", supply: 50, price: 3 },
        { name: "humanoid Head", supply: 40, price: 4 },
        { name: "robot Head", supply: 30, price: 5 },
        { name: "alien Head", supply: 20, price: 6 },
        { name: "gold Head", supply: 10, price: 7 },
        { name: "monkey", supply: 20, price: 8 },
        { name: "blue Head", supply: 50, price: 9 },
        { name: "green Head", supply: 40, price: 2 },
        { name: "red Head", supply: 30, price: 3 },
        { name: "skull", supply: 20, price: 4 },
        { name: "zombie Head", supply: 10, price: 5 },
    ];

    // Mouth Options
    const mouthOptions = [
        { name: "vampire mouth", supply: 10, price: 3 },
        { name: "butter", supply: 20, price: 4 },
        { name: "big smile", supply: 10, price: 5 },
        { name: "happy", supply: 30, price: 3 },
        { name: "pearly teeth", supply: 30, price: 4 },
        { name: "smile", supply: 30, price: 5 },
        { name: "smiley tongue", supply: 30, price: 3 },
        { name: "tobacco pipe", supply: 20, price: 4 },
        { name: "tongueout", supply: 50, price: 5 },
    ];

    // Eye Color Options
    const eyeColorOptions = [
        { name: "hypnotize Eyes", supply: 40, price: 25 },
        { name: "rainbowSpiral Eyes", supply: 10, price: 35 },
        { name: "double Eyes", supply: 20, price: 45 },
        { name: "yellow Eyes", supply: 40, price: 55 },
        { name: "black Eyes", supply: 40, price: 25 },
        { name: "blue Spirals", supply: 30, price: 35 },
        { name: "gold Eyes", supply: 5, price: 45 },
        { name: "green Spirals", supply: 20, price: 55 },
        { name: "white Eyes", supply: 10, price: 25 },
        { name: "yellow Spirals", supply: 30, price: 35 },
    ];

    // Body Options
    const bodyOptions = [
        { name: "robot Body", supply: 70, price: 18 },
        { name: "original Body", supply: 60, price: 28 },
        { name: "green Body", supply: 50, price: 38 },
        { name: "gold Tuxedo", supply: 40, price: 48 },
        { name: "old 1800s Outfit", supply: 30, price: 58 },
        { name: "alien Hoodie", supply: 20, price: 68 },
        { name: "blue Body", supply: 10, price: 78 },
        { name: "chefs Coat", supply: 70, price: 18 },
        { name: "clown Outfit", supply: 60, price: 28 },
        { name: "construction Outfit", supply: 50, price: 38 },
        { name: "fireFighter", supply: 40, price: 48 },
        { name: "green Body", supply: 30, price: 58 },
        { name: "grey Body", supply: 20, price: 68 },
        { name: "monkey Torso", supply: 10, price: 78 },
        { name: "native Outfit", supply: 70, price: 18 },
        { name: "peace Sign Army Guy", supply: 60, price: 28 },
        { name: "police Uniform", supply: 50, price: 38 },
        { name: "princess Dress", supply: 40, price: 48 },
        { name: "prison Jumpsuit", supply: 30, price: 58 },
        { name: "psycho Chibi", supply: 10, price: 68 },
        { name: "rain Coat", supply: 70, price: 18 },
        { name: "red Body", supply: 60, price: 28 },
        { name: "robe", supply: 50, price: 38 },
        { name: "samaraui OutFit", supply: 40, price: 48 },
        { name: "SGB Hoodie", supply: 30, price: 58 },
        { name: "skeleton", supply: 20, price: 68 },
        { name: "space Suit", supply: 10, price: 78 },
        { name: "unicorn Onsie", supply: 70, price: 18 },
        { name: "white Tuxedo", supply: 60, price: 28 },
        
        
    ];

    // Back Options
    const backOptions = [
        { name: "AK", supply: 40, price: 35 },
        { name: "Angel Wings", supply: 20, price: 45 },
        { name: "Rocket Launcher", supply: 30, price: 35 },
        { name: "Songbird Slugger", supply: 10, price: 45 },
        { name: "Unicorn AK", supply: 10, price: 35 },
    ];

    // Background Options
    const backgroundOptions = [
        { name: "pink Gradientbg", supply: 80, price: 12 },
        { name: "green Gradientbg", supply: 70, price: 22 },
        { name: "blue Gradientbg", supply: 60, price: 32 },
        { name: "yellow Gradientbg", supply: 50, price: 42 },
        { name: "dotted Swirlsbg", supply: 30, price: 52 },
        { name: "foil bg", supply: 5, price: 62 },
        { name: "illusion bg", supply: 20, price: 72 },
        { name: "illusion Spinningbg", supply: 10, price: 82 },
        { name: "orange Gradientbg", supply: 80, price: 12 },
        { name: "purple Wavesbg", supply: 20, price: 22 },
    ];

   
    


    // Function to add traits
    async function addTraits(traitTypeString, options) {
    const traitType = traitTypeMapping[traitTypeString];
    for (let i = 0; i < options.length; i++) {
        const option = options[i];
        console.log(`Adding ${traitTypeString} trait: ${option.name}`);
        await chibiFactory.addTrait(traitType, i, option.supply, option.price, option.name);
    }
}


  // Example collaboration trait options
  const picklesBodyOption = {
    name: "Pickles Body", // The name of the collaboration trait
    supply: 50,          // Total supply of this trait
    price: 10,           // Price for this trait in the specified ERC20 token
    erc20TokenAddress: "0x088F52912569071A49e71E7c4804915c36ECdCc8"  // The ERC20 token address for the collaboration (replace with actual address)
};

// Function to add collaboration traits
async function addCollabTraits(traitTypeString, option, erc20TokenAddress) {
    try {
        const traitType = traitTypeMapping[traitTypeString];
        console.log(`Attempting to add collaboration ${traitTypeString} trait: ${option.name}`);
        const tx = await chibiFactory.addCollabTrait(traitType, picklesBodyOption.supply, picklesBodyOption.price, picklesBodyOption.erc20TokenAddress, picklesBodyOption.name);
        const receipt = await tx.wait();
        console.log("Transaction receipt:", receipt);
                console.log(`Collaboration trait added successfully: ${option.name} with transaction hash: ${receipt.transactionHash}`);
    } catch (error) {
        console.error(`Error adding collaboration trait: ${error.message}`);
    }
}

// Adding collaboration trait

 



    // Add Traits
    await addTraits("Hat", hatOptions);
    await addTraits("Accessory", accessoryOptions);
    await addTraits("Head", headOptions);
    await addTraits("Mouth", mouthOptions);
    await addTraits("EyeColor", eyeColorOptions);
    await addTraits("Body", bodyOptions);
    await addTraits("Back", backOptions);
    await addTraits("Background", backgroundOptions);
    await addCollabTraits("Body", picklesBodyOption, picklesBodyOption.erc20TokenAddress);

  
    
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
