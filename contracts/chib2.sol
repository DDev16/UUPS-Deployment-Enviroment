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
    enum BackgroundOptions { PinkGradient, GreenGradient, BlueGradient, YellowGradient }

    struct Traits {
        HatOptions hat;
        HeadOptions head;
        MouthOptions mouth;
        EyeColorOptions eyeColor;
        BodyOptions body;
        BackgroundOptions background;
    }

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
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);
    
    ownsHatTrait[msg.sender][hatOption] = true;
    }

    function purchaseHeadTrait(HeadOptions headOption) public {
    uint256 price = headPrices[headOption];
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);

    ownsHeadTrait[msg.sender][headOption] = true;
    }

    function purchaseMouthTrait(MouthOptions mouthOption) public {
    uint256 price = mouthPrices[mouthOption];
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);

    ownsMouthTrait[msg.sender][mouthOption] = true;
    }

    function purchaseEyeColorTrait(EyeColorOptions eyeColorOption) public {
    uint256 price = eyeColorPrices[eyeColorOption];
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);

    ownsEyeColorTrait[msg.sender][eyeColorOption] = true;
    }

    function purchaseBodyTrait(BodyOptions bodyOption) public {
    uint256 price = bodyPrices[bodyOption];
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);

    ownsBodyTrait[msg.sender][bodyOption] = true;
    }

    function purchaseBackgroundTrait(BackgroundOptions backgroundOption) public {
    uint256 price = backgroundPrices[backgroundOption];
    require(erc20Token.balanceOf(msg.sender) >= price, "Insufficient ERC20 balance");
    erc20Token.transferFrom(msg.sender, address(this), price);

    ownsBackgroundTrait[msg.sender][backgroundOption] = true;
    }


   
  
   
  
    function mergeTraitsAndMintNFT(HatOptions hat, HeadOptions head, MouthOptions mouth, EyeColorOptions eyeColor, BodyOptions body, BackgroundOptions background) public returns (uint256) {
    
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
}