// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract SimpleChibifactory is ERC721Upgradeable, ERC721URIStorageUpgradeable, OwnableUpgradeable, UUPSUpgradeable  {
    uint256 private _nextTokenId;
    string public baseURI;
    uint256 public maxSupply;

    enum TraitType { Hat, Accessories, Head, Mouth, EyeColor, BackAccessories, Body, Background }
    struct Trait {
        TraitType traitType;
        uint256 option;
    }

    struct TraitData {
    uint256 supply;
    uint256 price;
    string name; 
}

struct TraitInfo {
    TraitType traitType;
    uint256 option;
    string name;
}



    mapping(TraitType => TraitData[]) public traits;
    mapping(uint256 => Trait[]) public tokenTraits;
    IERC20 public erc20Token;

    event TraitPurchased(address indexed user, TraitType traitType, uint256 option);
    event MintNFT(uint256 indexed tokenId, Trait[] traits);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function initialize(address _tokenAddress) initializer public {
        __ERC721_init("chibifactory", "CHB");
        __ERC721URIStorage_init();
        __Ownable_init(msg.sender);
        erc20Token = IERC20(_tokenAddress);
        _nextTokenId = 1; 
        baseURI = "";
        maxSupply = 10000;
        
    }

    function purchaseTrait(TraitType traitType, uint256 option) public {
        TraitData storage data = traits[traitType][option];
        require(data.supply > 0, "Option sold out");
        require(erc20Token.balanceOf(msg.sender) >= data.price, "Insufficient ERC20 balance");

        erc20Token.transferFrom(msg.sender, address(this), data.price);
        data.supply--;

        emit TraitPurchased(msg.sender, traitType, option);
    }

        function mintNFT(Trait[] memory _traits) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        for (uint i = 0; i < _traits.length; i++) {
            require(traits[_traits[i].traitType][_traits[i].option].supply > 0, "Trait option sold out");
            traits[_traits[i].traitType][_traits[i].option].supply--;

            // Assign each trait individually
            tokenTraits[tokenId].push(_traits[i]);
        }

        _safeMint(msg.sender, tokenId);
        emit MintNFT(tokenId, _traits);

        return tokenId;
    }

      



    function addTrait(TraitType traitType, uint256 option, uint256 supply, uint256 price, string memory name) public onlyOwner {
    // Ensure the option does not already exist for the traitType
    require(option == traits[traitType].length, "Option already exists");

    // Add the new trait option
    traits[traitType].push(TraitData(supply, price, name));
}






    function viewTokenTraits(uint256 tokenId) public view returns (string[] memory) {
    require(_exists(tokenId), "Token does not exist");

    Trait[] memory traitsArray = tokenTraits[tokenId];
    string[] memory traitNames = new string[](traitsArray.length);

    for (uint256 i = 0; i < traitsArray.length; i++) {
        TraitType traitType = traitsArray[i].traitType;
        uint256 option = traitsArray[i].option;

        traitNames[i] = traits[traitType][option].name;
    }

    return traitNames;
}



    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function setERC20TokenAddress(address _tokenAddress) external onlyOwner {
        erc20Token = IERC20(_tokenAddress);
    }



  function _exists(uint256 tokenId) internal view returns (bool) {
    return tokenId > 0 && tokenId < _nextTokenId;
}


    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}


    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

     function updateTokenURI(uint256 tokenId, string memory newTokenURI) public {
    require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

    // Call the _setTokenURI function from the ERC721URIStorageUpgradeable contract
    super._setTokenURI(tokenId, newTokenURI);
}

   function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}


