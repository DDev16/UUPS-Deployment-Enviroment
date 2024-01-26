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
        { name: "kitty", supply: 1000, price: 1 },
        { name: "SGB beanie", supply: 800, price: 2 },
        { name: "toad", supply: 500, price: 3 },
        { name: "spinny cap", supply: 700, price: 4 },
        { name: "mohawk", supply: 400, price: 5 },
        { name: "samaraui", supply: 300, price: 6 },
        { name: "alien antennaas", supply: 200, price: 7 },
        { name: "astronuaght Helmet", supply: 100, price: 8 },
        { name: "black Hair", supply: 600, price: 9 },
        { name: "clown Hat", supply: 500, price: 1 },
        { name: "construction Hat", supply: 400, price: 2 },
        { name: "devil Horns", supply: 300, price: 3 },
        { name: "firefighter Helmet", supply: 200, price: 4 },
        { name: "golden Poo", supply: 100, price: 5 },
        { name: "grey SGB Beanie", supply: 600, price: 6 },
        { name: "halo", supply: 500, price: 7 },
        { name: "headderess", supply: 400, price: 8 },
        { name: "headphones", supply: 300, price: 9 },
        { name: "hippy Bucket Hat", supply: 200, price: 1 },
        { name: "kings Crown", supply: 100, price: 2 },
        { name: "NFT Cap", supply: 600, price: 3 },
        { name: "NFT Songbird Beanie", supply: 500, price: 4 },
    ];

    // Accessory Options
    const accessoryOptions = [
        { name: "Bandana", supply: 500, price: 15 },
        { name: "EyePatch", supply: 400, price: 25 },
        { name: "Flare Tattoo", supply: 300, price: 35 },
        { name: "LolliPop", supply: 200, price: 45 },
        { name: "PsychoFlower", supply: 100, price: 55 },
        { name: "PsychoGemStaff", supply: 500, price: 15 },
        { name: "PsychoGem", supply: 400, price: 25 },
    ];

    // Head Options
    const headOptions = [
        { name: "original Head", supply: 600, price: 2 },
        { name: "green Alien Head", supply: 500, price: 3 },
        { name: "humanoid Head", supply: 400, price: 4 },
        { name: "robot Head", supply: 300, price: 5 },
        { name: "alien Head", supply: 200, price: 6 },
        { name: "gold Head", supply: 100, price: 7 },
        { name: "monkey", supply: 600, price: 8 },
        { name: "blue Head", supply: 500, price: 9 },
        { name: "green Head", supply: 400, price: 2 },
        { name: "red Head", supply: 300, price: 3 },
        { name: "skull", supply: 200, price: 4 },
        { name: "zombie Head", supply: 100, price: 5 },
    ];

    // Mouth Options
    const mouthOptions = [
        { name: "vampire mouth", supply: 300, price: 3 },
        { name: "butter", supply: 200, price: 4 },
        { name: "big smile", supply: 100, price: 5 },
        { name: "happy", supply: 300, price: 3 },
        { name: "pearly teeth", supply: 200, price: 4 },
        { name: "smile", supply: 100, price: 5 },
        { name: "smiley tongue", supply: 300, price: 3 },
        { name: "tobacco pipe", supply: 200, price: 4 },
        { name: "tongueout", supply: 100, price: 5 },
    ];

    // Eye Color Options
    const eyeColorOptions = [
        { name: "hypnotize Eyes", supply: 400, price: 25 },
        { name: "rainbowSpiral Eyes", supply: 300, price: 35 },
        { name: "double Eyes", supply: 200, price: 45 },
        { name: "yellow Eyes", supply: 100, price: 55 },
        { name: "black Eyes", supply: 400, price: 25 },
        { name: "blue Spirals", supply: 300, price: 35 },
        { name: "gold Eyes", supply: 200, price: 45 },
        { name: "green Spirals", supply: 100, price: 55 },
        { name: "white Eyes", supply: 400, price: 25 },
        { name: "yellow Spirals", supply: 300, price: 35 },
    ];

    // Body Options
    const bodyOptions = [
        { name: "robot Body", supply: 700, price: 18 },
        { name: "original Body", supply: 600, price: 28 },
        { name: "green Body", supply: 500, price: 38 },
        { name: "gold Tuxedo", supply: 400, price: 48 },
        { name: "old 1800s Outfit", supply: 300, price: 58 },
        { name: "alien Hoodie", supply: 200, price: 68 },
        { name: "blue Body", supply: 100, price: 78 },
        { name: "chefs Coat", supply: 700, price: 18 },
        { name: "clown Outfit", supply: 600, price: 28 },
        { name: "construction Outfit", supply: 500, price: 38 },
        { name: "fireFighter", supply: 400, price: 48 },
        { name: "green Body", supply: 300, price: 58 },
        { name: "grey Body", supply: 200, price: 68 },
        { name: "monkey Torso", supply: 100, price: 78 },
        { name: "native Outfit", supply: 700, price: 18 },
        { name: "peace Sign Army Guy", supply: 600, price: 28 },
        { name: "police Uniform", supply: 500, price: 38 },
        { name: "princess Dress", supply: 400, price: 48 },
        { name: "prison Jumpsuit", supply: 300, price: 58 },
        { name: "psycho Chibi", supply: 200, price: 68 },
    ];

    // Back Options
    const backOptions = [
        { name: "AK", supply: 200, price: 35 },
        { name: "Angel Wings", supply: 100, price: 45 },
        { name: "Rocket Launcher", supply: 200, price: 35 },
        { name: "Songbird Slugger", supply: 100, price: 45 },
        { name: "Unicorn AK", supply: 200, price: 35 },
    ];

    // Background Options
    const backgroundOptions = [
        { name: "pink Gradientbg", supply: 800, price: 12 },
        { name: "green Gradientbg", supply: 700, price: 22 },
        { name: "blue Gradientbg", supply: 600, price: 32 },
        { name: "yellow Gradientbg", supply: 500, price: 42 },
        { name: "dotted Swirlsbg", supply: 400, price: 52 },
        { name: "foil bg", supply: 300, price: 62 },
        { name: "illusion bg", supply: 200, price: 72 },
        { name: "illusion Spinningbg", supply: 100, price: 82 },
        { name: "orange Gradientbg", supply: 800, price: 12 },
        { name: "purple Wavesbg", supply: 700, price: 22 },
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


    // Add Traits
    await addTraits("Hat", hatOptions);
    await addTraits("Accessory", accessoryOptions);
    await addTraits("Head", headOptions);
    await addTraits("Mouth", mouthOptions);
    await addTraits("EyeColor", eyeColorOptions);
    await addTraits("Body", bodyOptions);
    await addTraits("Back", backOptions);
    await addTraits("Background", backgroundOptions);
}

main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
