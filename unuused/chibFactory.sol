// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Chibifactory1 is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721PausableUpgradeable, OwnableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable {
    uint256 private _nextTokenId;
    string public baseURI;
    string public baseExtension;
    uint256 public maxSupply;

    enum HatOptions { Kitty, SGBBeanie, Toad, SpinyCap, Mohawk, Samurai }
    enum HeadOptions { OriginalHead, GreenAlienHead, HumanoidHead, RobotHead, AlienHead, GoldHead, Monkey }
    enum MouthOptions { VampireMouth, Butter }
    enum EyeColorOptions { HypnotizeEyes, RainbowSpiralEyes, DoubleEyes, YellowEyes, BlackEyes, BlueEyes }
    enum BodyOptions { RobotBody, OriginalBody, GreenBody, GoldTuxedo }
    enum BackgroundOptions { PinkGradient, GreenGradient, BlueGradient, YellowGradient, Holo, Illusion, Spiral, Dotted, WavesOfIllusions}

    struct Traits {
        HatOptions hat;
        HeadOptions head;
        MouthOptions mouth;
        EyeColorOptions eyeColor;
        BodyOptions body;
        BackgroundOptions background;
    }


       
    mapping(HatOptions => uint256) public hatSupply;
    mapping(HeadOptions => uint256) public headSupply;
    mapping(MouthOptions => uint256) public mouthSupply;
    mapping(EyeColorOptions => uint256) public eyeColorSupply;
    mapping(BodyOptions => uint256) public bodySupply;
    mapping(BackgroundOptions => uint256) public backgroundSupply;



    mapping(uint256 => Traits) public tokenTraits;

    

    mapping(HatOptions => uint256) public hatPrices;
   
    mapping(HeadOptions => uint256) public headPrices;
   
    mapping(MouthOptions => uint256) public mouthPrices;
   
    mapping(EyeColorOptions => uint256) public eyeColorPrices;
  
    mapping(BodyOptions => uint256) public bodyPrices;
   
    mapping(BackgroundOptions => uint256) public backgroundPrices;

    mapping(address => mapping(HatOptions => bool)) public ownsHatTrait;
    mapping(address => mapping(HeadOptions => bool)) public ownsHeadTrait;
    mapping(address => mapping(MouthOptions => bool)) public ownsMouthTrait;
    mapping(address => mapping(EyeColorOptions => bool)) public ownsEyeColorTrait;
    mapping(address => mapping(BodyOptions => bool)) public ownsBodyTrait;
    mapping(address => mapping(BackgroundOptions => bool)) public ownsBackgroundTrait;


    IERC20 public erc20Token;
  

    event TraitSwapped(uint256 indexed tokenId, HatOptions newHat, HeadOptions newHead, MouthOptions newMouth, EyeColorOptions newEyeColor, BodyOptions newBody, BackgroundOptions newBackground);
    event TraitPurchased(address indexed user, HatOptions hatOption, HeadOptions headOption, MouthOptions mouthOption, EyeColorOptions eyeColorOption, BodyOptions bodyOption, BackgroundOptions backgroundOption);
    event TraitPriceUpdated(HatOptions hatOption, HeadOptions headOption, MouthOptions mouthOption, EyeColorOptions eyeColorOption, BodyOptions bodyOption, BackgroundOptions backgroundOption);
    event MintNFT(
        HatOptions hat,
        HeadOptions head,
        MouthOptions mouth,
        EyeColorOptions eyeColor,
        BodyOptions body,
        BackgroundOptions background,
        uint256 tokenId
    );
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _tokenAddress) initializer public {
        __ERC721_init("chibifactory", "CHB");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __Ownable_init(msg.sender);
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();
        erc20Token = IERC20(_tokenAddress);
        _nextTokenId = 1; 
        baseExtension = ".json";
        baseURI = "";
        maxSupply = 10000;

        hatPrices[HatOptions.Kitty] = 100000000000000000000;
        hatPrices[HatOptions.SGBBeanie] = 100000000000000000000;
        hatPrices[HatOptions.Toad] = 100000000000000000000;
        hatPrices[HatOptions.SpinyCap] = 100000000000000000000;
        hatPrices[HatOptions.Mohawk] = 100000000000000000000;
        hatPrices[HatOptions.Samurai] = 100000000000000000000;

        headPrices[HeadOptions.OriginalHead] = 100000000000000000000;
        headPrices[HeadOptions.GreenAlienHead] = 100000000000000000000;
        headPrices[HeadOptions.HumanoidHead] = 100000000000000000000;
        headPrices[HeadOptions.RobotHead] = 100000000000000000000;
        headPrices[HeadOptions.AlienHead] = 100000000000000000000;
        headPrices[HeadOptions.GoldHead] = 100000000000000000000;
        headPrices[HeadOptions.Monkey] = 100000000000000000000;

        mouthPrices[MouthOptions.VampireMouth] = 100000000000000000000;
        mouthPrices[MouthOptions.Butter] = 100000000000000000000;

        eyeColorPrices[EyeColorOptions.HypnotizeEyes] = 100000000000000000000;
        eyeColorPrices[EyeColorOptions.RainbowSpiralEyes] = 100000000000000000000;
        eyeColorPrices[EyeColorOptions.DoubleEyes] = 100000000000000000000;
        eyeColorPrices[EyeColorOptions.YellowEyes] = 100000000000000000000;
        eyeColorPrices[EyeColorOptions.BlackEyes] = 100000000000000000000;
        eyeColorPrices[EyeColorOptions.BlueEyes] = 100000000000000000000;

        bodyPrices[BodyOptions.RobotBody] = 100000000000000000000;
        bodyPrices[BodyOptions.OriginalBody] = 100000000000000000000;
        bodyPrices[BodyOptions.GreenBody] = 100000000000000000000;
        bodyPrices[BodyOptions.GoldTuxedo] = 100000000000000000000;

        backgroundPrices[BackgroundOptions.PinkGradient] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.GreenGradient] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.BlueGradient] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.YellowGradient] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.Holo] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.Illusion] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.Spiral] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.Dotted] = 100000000000000000000;
        backgroundPrices[BackgroundOptions.WavesOfIllusions] = 100000000000000000000;


        // Set the initial trait supply
         hatSupply[HatOptions.Kitty] = 100; 
        hatSupply[HatOptions.SGBBeanie] = 100;
        hatSupply[HatOptions.Toad] = 100;
        hatSupply[HatOptions.SpinyCap] = 100;
        hatSupply[HatOptions.Mohawk] = 100;

         headSupply[HeadOptions.OriginalHead] = 100;  // Set the initial supply for each head option
        headSupply[HeadOptions.GreenAlienHead] = 100;
        headSupply[HeadOptions.HumanoidHead] = 100;
        headSupply[HeadOptions.RobotHead] = 100;
        headSupply[HeadOptions.AlienHead] = 100;
        headSupply[HeadOptions.GoldHead] = 100;
        headSupply[HeadOptions.Monkey] = 100;

        mouthSupply[MouthOptions.VampireMouth] = 100;  // Set the initial supply for each mouth option
        mouthSupply[MouthOptions.Butter] = 100;
            
        eyeColorSupply[EyeColorOptions.HypnotizeEyes] = 100;  // Set the initial supply for each eye color option
        eyeColorSupply[EyeColorOptions.RainbowSpiralEyes] = 100;
        eyeColorSupply[EyeColorOptions.DoubleEyes] = 100;
        eyeColorSupply[EyeColorOptions.YellowEyes] = 100;
        eyeColorSupply[EyeColorOptions.BlackEyes] = 100;
        eyeColorSupply[EyeColorOptions.BlueEyes] = 100;

         bodySupply[BodyOptions.RobotBody] = 100;  // Set the initial supply for each body option
        bodySupply[BodyOptions.OriginalBody] = 100;
        bodySupply[BodyOptions.GreenBody] = 100;
        bodySupply[BodyOptions.GoldTuxedo] = 100;

         backgroundSupply[BackgroundOptions.PinkGradient] = 100;  // Set the initial supply for each background option
        backgroundSupply[BackgroundOptions.GreenGradient] = 100;
        backgroundSupply[BackgroundOptions.BlueGradient] = 100;
        backgroundSupply[BackgroundOptions.YellowGradient] = 100;
        backgroundSupply[BackgroundOptions.Holo] = 100;
        backgroundSupply[BackgroundOptions.Illusion] = 100;
        backgroundSupply[BackgroundOptions.Spiral] = 100;
        backgroundSupply[BackgroundOptions.Dotted] = 100;
        backgroundSupply[BackgroundOptions.WavesOfIllusions] = 100;


    }

    
    function tokenURI(uint256 tokenId)
                public
                view
                override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
                returns (string memory)
            {
                return super.tokenURI(tokenId);
            }

    




    function purchaseHatTrait(HatOptions hatOption) public {
    uint256 price = hatPrices[hatOption];

    // Check if the supply for the hat option has run out
    require(hatSupply[hatOption] > 0, "Hat option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified hat trait
    ownsHatTrait[msg.sender][hatOption] = true;

    // Decrement the supply for the hat option
    hatSupply[hatOption]--;
}

function purchaseHeadTrait(HeadOptions headOption) public {
    uint256 price = headPrices[headOption];

    // Check if the supply for the head option has run out
    require(headSupply[headOption] > 0, "Head option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified head trait
    ownsHeadTrait[msg.sender][headOption] = true;

    // Decrement the supply for the head option
    headSupply[headOption]--;
}

   function purchaseMouthTrait(MouthOptions mouthOption) public {
    uint256 price = mouthPrices[mouthOption];

    // Check if the supply for the mouth option has run out
    require(mouthSupply[mouthOption] > 0, "Mouth option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified mouth trait
    ownsMouthTrait[msg.sender][mouthOption] = true;

    // Decrement the supply for the mouth option
    mouthSupply[mouthOption]--;
}

function purchaseEyeColorTrait(EyeColorOptions eyeColorOption) public {
    uint256 price = eyeColorPrices[eyeColorOption];

    // Check if the supply for the eye color option has run out
    require(eyeColorSupply[eyeColorOption] > 0, "Eye color option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified eye color trait
    ownsEyeColorTrait[msg.sender][eyeColorOption] = true;

    // Decrement the supply for the eye color option
    eyeColorSupply[eyeColorOption]--;
}

function purchaseBodyTrait(BodyOptions bodyOption) public {
    uint256 price = bodyPrices[bodyOption];

    // Check if the supply for the body option has run out
    require(bodySupply[bodyOption] > 0, "Body option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified body trait
    ownsBodyTrait[msg.sender][bodyOption] = true;

    // Decrement the supply for the body option
    bodySupply[bodyOption]--;
}


function purchaseBackgroundTrait(BackgroundOptions backgroundOption) public {
    uint256 price = backgroundPrices[backgroundOption];

    // Check if the supply for the background option has run out
    require(backgroundSupply[backgroundOption] > 0, "Background option sold out");

    // Check if the user has a sufficient ERC20 balance
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");

    // Transfer the required amount from the user to the contract
    erc20Token.transferFrom(msg.sender, address(this), price);

    // Mark that the user owns the specified background trait
    ownsBackgroundTrait[msg.sender][backgroundOption] = true;

    // Decrement the supply for the background option
    backgroundSupply[backgroundOption]--;
}

    function updateHatPrice(HatOptions hatOption, uint256 newPrice) public onlyOwner {
    hatPrices[hatOption] = newPrice;
    emit TraitPriceUpdated(hatOption, HeadOptions.OriginalHead, MouthOptions.VampireMouth, EyeColorOptions.HypnotizeEyes, BodyOptions.OriginalBody, BackgroundOptions.PinkGradient);
    }

    function updateHeadPrice(HeadOptions headOption, uint256 newPrice) public onlyOwner {
    headPrices[headOption] = newPrice;
    emit TraitPriceUpdated(HatOptions.Kitty, headOption, MouthOptions.VampireMouth, EyeColorOptions.HypnotizeEyes, BodyOptions.OriginalBody, BackgroundOptions.PinkGradient);
    }

    function updateMouthPrice(MouthOptions mouthOption, uint256 newPrice) public onlyOwner {
    mouthPrices[mouthOption] = newPrice;
    emit TraitPriceUpdated(HatOptions.Kitty, HeadOptions.OriginalHead, mouthOption, EyeColorOptions.HypnotizeEyes, BodyOptions.OriginalBody, BackgroundOptions.PinkGradient);
    }

    function updateEyeColorPrice(EyeColorOptions eyeColorOption, uint256 newPrice) public onlyOwner {
    eyeColorPrices[eyeColorOption] = newPrice;
    emit TraitPriceUpdated(HatOptions.Kitty, HeadOptions.OriginalHead, MouthOptions.VampireMouth, eyeColorOption, BodyOptions.OriginalBody, BackgroundOptions.PinkGradient);
    }

    function updateBodyPrice(BodyOptions bodyOption, uint256 newPrice) public onlyOwner {
    bodyPrices[bodyOption] = newPrice;
    emit TraitPriceUpdated(HatOptions.Kitty, HeadOptions.OriginalHead, MouthOptions.VampireMouth, EyeColorOptions.HypnotizeEyes, bodyOption, BackgroundOptions.PinkGradient);
    }

    function updateBackgroundPrice(BackgroundOptions backgroundOption, uint256 newPrice) public onlyOwner {
    backgroundPrices[backgroundOption] = newPrice;
    emit TraitPriceUpdated(HatOptions.Kitty, HeadOptions.OriginalHead, MouthOptions.VampireMouth, EyeColorOptions.HypnotizeEyes, BodyOptions.OriginalBody, backgroundOption);
    }


   
  
    function mergeTraitsAndMintNFT(HatOptions hat, HeadOptions head, MouthOptions mouth, EyeColorOptions eyeColor, BodyOptions body, BackgroundOptions background) public returns (uint256) {
     // Check if the supply for each trait is greater than 0
    require(hatSupply[hat] > 0, "Hat option sold out");
    require(headSupply[head] > 0, "Head option sold out");
    require(mouthSupply[mouth] > 0, "Mouth option sold out");
    require(eyeColorSupply[eyeColor] > 0, "Eye color option sold out");
    require(bodySupply[body] > 0, "Body option sold out");
    require(backgroundSupply[background] > 0, "Background option sold out");


    // Decrement the supply for each trait
    hatSupply[hat]--;
    headSupply[head]--;
    mouthSupply[mouth]--;
    eyeColorSupply[eyeColor]--;
    bodySupply[body]--;
    backgroundSupply[background]--;

    uint256 tokenId = _nextTokenId++;
    tokenTraits[tokenId] = Traits({hat: hat, head: head, mouth: mouth, eyeColor: eyeColor, body: body, background: background});

    _safeMint(msg.sender, tokenId);
    emit MintNFT( hat, head, mouth, eyeColor, body, background, tokenId);

    // Return the tokenId of the minted NFT
    return tokenId;
}



    function updateTraits(uint256 tokenId, HatOptions newHat, HeadOptions newHead, MouthOptions newMouth, EyeColorOptions newEyeColor, BodyOptions newBody, BackgroundOptions newBackground) public {
    require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");
    
    // Check if the user owns the required traits to update.
    require(ownsHatTrait[msg.sender][newHat], "Does not own the Hat trait");
    require(ownsHeadTrait[msg.sender][newHead], "Does not own the Head trait");
    require(ownsMouthTrait[msg.sender][newMouth], "Does not own the Mouth trait");
    require(ownsEyeColorTrait[msg.sender][newEyeColor], "Does not own the EyeColor trait");
    require(ownsBodyTrait[msg.sender][newBody], "Does not own the Body trait");
    require(ownsBackgroundTrait[msg.sender][newBackground], "Does not own the Background trait");

    // Update the traits
    tokenTraits[tokenId].hat = newHat;
    tokenTraits[tokenId].head = newHead;
    tokenTraits[tokenId].mouth = newMouth;
    tokenTraits[tokenId].eyeColor = newEyeColor;
    tokenTraits[tokenId].body = newBody;
    tokenTraits[tokenId].background = newBackground;

    // Emit an event to notify about the trait update
    emit TraitSwapped(tokenId, newHat, newHead, newMouth, newEyeColor, newBody, newBackground);
}



    function getTokenTraits(uint256 tokenId) public view returns (Traits memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return tokenTraits[tokenId];
    }



    function updateTokenURI(uint256 tokenId, string memory newTokenURI) public {
    require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

    // Call the _setTokenURI function from the ERC721URIStorageUpgradeable contract
    super._setTokenURI(tokenId, newTokenURI);
}


  

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
    }


    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    

        function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }


    function setERC20TokenAddress(address _tokenAddress) external onlyOwner {
        erc20Token = IERC20(_tokenAddress);
    }


    // Getter functions to fetch trait prices
    function getHatPrice(HatOptions hatOption) public view returns (uint256) {
        return hatPrices[hatOption];
    }

    function getHeadPrice(HeadOptions headOption) public view returns (uint256) {
        return headPrices[headOption];
    }

    function getMouthPrice(MouthOptions mouthOption) public view returns (uint256) {
        return mouthPrices[mouthOption];
    }

    function getEyeColorPrice(EyeColorOptions eyeColorOption) public view returns (uint256) {
        return eyeColorPrices[eyeColorOption];
    }

    function getBodyPrice(BodyOptions bodyOption) public view returns (uint256) {
        return bodyPrices[bodyOption];
    }

    function getBackgroundPrice(BackgroundOptions backgroundOption) public view returns (uint256) {
        return backgroundPrices[backgroundOption];
    }
}