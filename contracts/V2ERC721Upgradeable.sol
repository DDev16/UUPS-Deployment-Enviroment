// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract NFTV2 is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721PausableUpgradeable, OwnableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {

    struct TokenWithBaseURI {
        uint256 tokenId;
        string baseURI;
    }

    string public baseURI;
    string public baseExtension;
    uint256 public presaleCost;
    uint256 public regularCost;
    uint256 public maxSupply;
    uint256 public maxMintAmount;
    bool public revealed;
    string public notRevealedUri;
    bool public presaleActive;
    uint256 public nftholderRewardPercentage;

    // Mapping to track rewards for NFTholders
    mapping(address => uint256) public nftholderRewards;

    // Owner's share mapping
    mapping(address => uint256) public ownerShares;

    event RevertReason(string reason);
    event Minted(address indexed minter, uint256 amount);
    event Claimed(address indexed claimer, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC721_init("NFTV2", "NFTV2");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __Ownable_init(initialOwner);
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        // Move initial value assignments to the constructor or initializers
        baseExtension = ".json";
        presaleCost = 5 ether;
        regularCost = 10 ether;
        maxSupply = 10000;
        maxMintAmount = 20;
        revealed = false;
        baseURI = "ipfs:hiuh323123hjtestnkdkasd4323/"; // Replace with your URI
        notRevealedUri = "ipfs:hiuh3231test23hjnkdkasd4323/"; // Replace with your URI
        presaleActive = true;
        nftholderRewardPercentage = 10;
    }





    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }


   // Function to toggle between presale and regular pricing mode
    function togglePricingMode() public onlyOwner {
        presaleActive = !presaleActive;
    }

    // Only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    // Set the NFTholder reward percentage, only callable by the owner
    function setNFTholderRewardPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage >= 0 && _percentage <= 100, "Invalid percentage");
        nftholderRewardPercentage = _percentage;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }

    function setRegularCost(uint256 _newCost) public onlyOwner {
        regularCost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause() public onlyOwner returns (bool) {
    _pause();
    return true;
}

function unpause() public onlyOwner returns (bool) {
    _unpause();
    return true;
}



  function mint(uint256 _mintAmount) public payable nonReentrant {
    uint256 supply = totalSupply();

    require(!paused(), "Minting is currently paused");
    require(_mintAmount > 0, "Mint amount must be greater than 0");
    require(_mintAmount <= maxMintAmount, "Mint amount exceeds the maximum allowed");
    require(supply + _mintAmount <= maxSupply, "Minting would exceed the maximum supply");

    uint256 cost = presaleActive ? presaleCost : regularCost;

    // Exempt the owner from paying any cost
    if (msg.sender != owner()) {
        require(msg.value >= cost * _mintAmount, "Insufficient payment for minting");
        
        // Calculate the NFTholder reward based on the specified percentage
        uint256 nftholderReward = (cost * nftholderRewardPercentage * _mintAmount) / 100;
        nftholderRewards[msg.sender] += nftholderReward;
        
        // Update owner's share
        ownerShares[owner()] += msg.value - nftholderReward;
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
        _safeMint(msg.sender, supply + i);
    }
}

      // Function to claim NFTholder rewards
    function claimRewards() public nonReentrant {
        require(nftholderRewards[msg.sender] > 0, "No rewards to claim");
        uint256 rewards = nftholderRewards[msg.sender];
        nftholderRewards[msg.sender] = 0;
        payable(msg.sender).transfer(rewards);
                emit Claimed(msg.sender, rewards);

    }

    // Function to withdraw the owner's share
    function withdrawOwnerShare() public onlyOwner nonReentrant {
        require(ownerShares[owner()] > 0, "No owner's share to withdraw");
        uint256 share = ownerShares[owner()];
        ownerShares[owner()] = 0;
        payable(owner()).transfer(share);
    }

    // Emergency withdrawal function for leftover funds
    function emergencyWithdraw() public onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        payable(owner()).transfer(contractBalance);
    }

    
 // Function to fetch token IDs and their base URIs
function getTokenIdsWithBaseURIs() public view returns (TokenWithBaseURI[] memory) {
    uint256 totalTokens = totalSupply();
    TokenWithBaseURI[] memory tokenInfo = new TokenWithBaseURI[](totalTokens);

    for (uint256 i = 0; i < totalTokens; i++) {
        uint256 tokenId = tokenByIndex(i);
        string memory tokenIdStr = uint256ToString(tokenId);
        string memory tokenBaseURI = string(abi.encodePacked(baseURI, tokenIdStr, baseExtension));
        tokenInfo[i] = TokenWithBaseURI(tokenId, tokenBaseURI);
    }

    return tokenInfo;
}

function uint256ToString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp > 0) {
        temp /= 10;
        digits++;
    }
    bytes memory buffer = new bytes(digits);
    while (value > 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}

 
  function version() pure public returns (string memory) {
        return "v4!";
    }


    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

  
   
}
