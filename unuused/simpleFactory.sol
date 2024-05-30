// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleChibifactory is
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 private _nextTokenId;
    string public baseURI;
    uint256 public maxSupply;

    enum TraitType {
        Hat,
        Accessories,
        Head,
        Mouth,
        EyeColor,
        BackAccessories,
        Body,
        Background
    }
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

    struct TraitSale {
        bool isForSale;
        uint256 option;
        uint256 price;
        address seller;
    }

    // Struct to hold sale information for easier return from function
struct SaleInfo {
    TraitType traitType;
    uint256 option;
    uint256 price;
    address seller;
}

struct CollabTrait {
    uint256 price;
    address erc20TokenAddress;
    string name;
    uint256 supply;
}

// Mapping to store collaboration traits
mapping(TraitType => mapping(uint256 => CollabTrait)) public collabTraits;

mapping(bytes32 => bool) private mintedTraitCombinations;

    mapping(address => mapping(TraitType => mapping(uint256 => uint256)))
        public ownedTraits;

mapping(TraitType => mapping(uint256 => TraitSale)) public traitSales;
    mapping(TraitType => TraitData[]) public traits;
    mapping(uint256 => Trait[]) public tokenTraits;
    IERC20 public erc20Token;

    event TraitPurchased(
        address indexed user,
        TraitType traitType,
        uint256 option
    );
    event MintNFT(uint256 indexed tokenId, Trait[] traits);
    event TraitListedForSale(
        TraitType traitType,
        uint256 option,
        uint256 price
    );
    event TraitSaleCancelled(uint256 indexed tokenId, TraitType traitType);
    event TraitBought(
        TraitType traitType,
        uint256 option,
        address buyer,
        address seller,
        uint256 price
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _tokenAddress) public initializer {
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
        require(
            erc20Token.balanceOf(msg.sender) >= data.price,
            "Insufficient ERC20 balance"
        );

        erc20Token.transferFrom(msg.sender, address(this), data.price);
        data.supply--;
        ownedTraits[msg.sender][traitType][option] += 1;

        emit TraitPurchased(msg.sender, traitType, option);
    }

     function buyTrait(TraitType traitType, uint256 option) public {
        TraitSale storage sale = traitSales[traitType][option];
        require(sale.isForSale, "Trait not for sale");
        require(erc20Token.balanceOf(msg.sender) >= sale.price, "Insufficient ERC20 balance");

        erc20Token.transferFrom(msg.sender, sale.seller, sale.price);
        ownedTraits[sale.seller][traitType][option]--;
        ownedTraits[msg.sender][traitType][option]++;

        sale.isForSale = false;

        emit TraitBought(traitType, option, msg.sender, sale.seller, sale.price);
    }


    function mintNFT(Trait[] memory _traits) public returns (uint256) {
    require(_traits.length > 0, "No traits provided");

    // Initialize an empty bytes array for traits encoding
    bytes memory traitsEncoding = "";

    for (uint256 i = 0; i < _traits.length; i++) {
        // Encode each trait and concatenate
        traitsEncoding = abi.encodePacked(
            traitsEncoding,
            abi.encode(_traits[i].traitType, _traits[i].option)
        );

        // Check if the user owns the trait
        require(
            ownedTraits[msg.sender][_traits[i].traitType][_traits[i].option] > 0,
            "User does not own the required trait"
        );

        // Decrement the owned trait count
        ownedTraits[msg.sender][_traits[i].traitType][_traits[i].option]--;
    }

    // Generate a unique identifier for the trait combination
    bytes32 traitHash = keccak256(traitsEncoding);
    require(!mintedTraitCombinations[traitHash], "Traits combination already minted");

    uint256 tokenId = _nextTokenId++;
    for (uint256 i = 0; i < _traits.length; i++) {
        require(
            traits[_traits[i].traitType][_traits[i].option].supply > 0,
            "Trait option sold out"
        );
        traits[_traits[i].traitType][_traits[i].option].supply--;
        tokenTraits[tokenId].push(_traits[i]);
    }

    mintedTraitCombinations[traitHash] = true;

    _safeMint(msg.sender, tokenId);
    emit MintNFT(tokenId, _traits);

    return tokenId;
}



    function addTrait(
        TraitType traitType,
        uint256 option,
        uint256 supply,
        uint256 price,
        string memory name
    ) public onlyOwner {
        // Ensure the option does not already exist for the traitType
        require(option == traits[traitType].length, "Option already exists");

        // Add the new trait option
        traits[traitType].push(TraitData(supply, price, name));
    }

    function listTraitForSale(
        TraitType traitType,
        uint256 option,
        uint256 price
    ) public {
        require(
            ownedTraits[msg.sender][traitType][option] > 0,
            "You do not own this trait"
        );

        traitSales[traitType][option] = TraitSale({
            isForSale: true,
            option: option,

            price: price,
            seller: msg.sender
        });

        emit TraitListedForSale(traitType, option, price);
    }

    
    // Utility function to check if a trait type and option exist
    function traitTypeExists(TraitType traitType, uint256 option)
        internal
        view
        returns (bool)
    {
        return option < traits[traitType].length;
    }

    function viewTokenTraits(uint256 tokenId)
        public
        view
        returns (string[] memory)
    {
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

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function updateTokenURI(uint256 tokenId, string memory newTokenURI) public {
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        // Call the _setTokenURI function from the ERC721URIStorageUpgradeable contract
        super._setTokenURI(tokenId, newTokenURI);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function purchaseCollabTrait(TraitType traitType, uint256 option) public {
    CollabTrait storage collabTrait = collabTraits[traitType][option];
    require(collabTrait.supply > 0, "Collab trait sold out");
    require(collabTrait.erc20TokenAddress != address(0), "Invalid ERC20 token address for collab trait");

    IERC20 collabToken = IERC20(collabTrait.erc20TokenAddress);
    require(
        collabToken.balanceOf(msg.sender) >= collabTrait.price,
        "Insufficient ERC20 balance for collab trait"
    );

    collabToken.transferFrom(msg.sender, address(this), collabTrait.price);
    collabTrait.supply--;
    ownedTraits[msg.sender][traitType][option] += 1;

    emit TraitPurchased(msg.sender, traitType, option);
}


    // Function to get all traits for sale
function getAllTraitsForSale() public view returns (SaleInfo[] memory) {
    uint256 saleCount = 0;

    // First, count the number of traits for sale
    for (uint256 t = 0; t < uint256(TraitType.Background) + 1; t++) {
        for (uint256 i = 0; i < traits[TraitType(t)].length; i++) {
            if (traitSales[TraitType(t)][i].isForSale) {
                saleCount++;
            }
        }
    }

    // Now, create an array to hold the sale info
    SaleInfo[] memory sales = new SaleInfo[](saleCount);
    uint256 saleIndex = 0;

    // Populate the array
    for (uint256 t = 0; t < uint256(TraitType.Background) + 1; t++) {
        for (uint256 i = 0; i < traits[TraitType(t)].length; i++) {
            if (traitSales[TraitType(t)][i].isForSale) {
                TraitSale storage sale = traitSales[TraitType(t)][i];
                sales[saleIndex] = SaleInfo({
                    traitType: TraitType(t),
                    option: i,
                    price: sale.price,
                    seller: sale.seller
                });
                saleIndex++;
            }
        }
    }

    return sales;
}

function getTraitSupplyAndPrice(TraitType traitType, uint256 option) 
    public 
    view 
    returns (uint256 supply, uint256 price) 
{
    require(traitTypeExists(traitType, option), "Trait type or option does not exist");

    TraitData storage data = traits[traitType][option];
    return (data.supply, data.price);
}

// Function to get all traits owned by a user
function getUserTraits(address user) public view returns (TraitInfo[] memory) {
    uint256 totalTraitsCount = 0;

    // First, count the total number of traits owned by the user
    for (uint256 t = 0; t <= uint256(TraitType.Background); t++) {
        for (uint256 i = 0; i < traits[TraitType(t)].length; i++) {
            if (ownedTraits[user][TraitType(t)][i] > 0) {
                totalTraitsCount += ownedTraits[user][TraitType(t)][i];
            }
        }
    }

    // Now, create an array to hold the trait info
    TraitInfo[] memory userTraits = new TraitInfo[](totalTraitsCount);
    uint256 traitIndex = 0;

    // Populate the array with the user's traits
    for (uint256 t = 0; t <= uint256(TraitType.Background); t++) {
        for (uint256 i = 0; i < traits[TraitType(t)].length; i++) {
            uint256 ownedCount = ownedTraits[user][TraitType(t)][i];
            if (ownedCount > 0) {
                for (uint256 j = 0; j < ownedCount; j++) {
                    TraitData storage data = traits[TraitType(t)][i];
                    userTraits[traitIndex] = TraitInfo({
                        traitType: TraitType(t),
                        option: i,
                        name: data.name
                    });
                    traitIndex++;
                }
            }
        }
    }

    return userTraits;
}

function listCollabTraitForSale(
    TraitType traitType,
    uint256 option,
    uint256 price
) public {
    require(
        ownedTraits[msg.sender][traitType][option] > 0,
        "You do not own this collab trait"
    );

    traitSales[traitType][option] = TraitSale({
        isForSale: true,
        option: option,
        price: price,
        seller: msg.sender
    });

    emit TraitListedForSale(traitType, option, price);
}


function buyCollabTrait(TraitType traitType, uint256 option) public {
    TraitSale storage sale = traitSales[traitType][option];
    require(sale.isForSale, "Collab trait not for sale");

    CollabTrait storage collabTrait = collabTraits[traitType][option];
    IERC20 collabToken = IERC20(collabTrait.erc20TokenAddress);

    require(collabToken.balanceOf(msg.sender) >= sale.price, "Insufficient ERC20 balance");

    collabToken.transferFrom(msg.sender, sale.seller, sale.price);
    ownedTraits[sale.seller][traitType][option]--;
    ownedTraits[msg.sender][traitType][option]++;

    sale.isForSale = false;

    emit TraitBought(traitType, option, msg.sender, sale.seller, sale.price);
}

function cancelCollabTraitListing(TraitType traitType, uint256 option) public {
    TraitSale storage sale = traitSales[traitType][option];
    require(sale.seller == msg.sender, "You are not the seller");
    require(sale.isForSale, "Trait not listed for sale");

    sale.isForSale = false;

}


// Function to add a collaboration trait
function addCollabTrait(
    TraitType traitType,
    uint256 supply,
    uint256 price,
    address erc20TokenAddress,
    string memory name
) public onlyOwner {
    uint256 option = traits[traitType].length; // Automatically determines the index
    require(erc20TokenAddress != address(0), "Invalid ERC20 token address");
    require(!traitTypeExists(traitType, option), "Collab trait already exists");

    collabTraits[traitType][option] = CollabTrait({
        price: price,
        erc20TokenAddress: erc20TokenAddress,
        name: name,
        supply: supply
    });
}



}
