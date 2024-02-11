// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

// Import the interface for the ERC20 token
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PsychoChibis is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721PausableUpgradeable, OwnableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {

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
     // Storage variables for accumulated funds
    uint256 public totalDelegationFunds;
    uint256 public totalLPFunds;

    uint256 private nonce;

    mapping(uint256 => bool) private mintedTokenIds;

    // Mapping to track rewards for NFTholders
    mapping(address => uint256) public nftholderRewards;

    // Mapping to track the number of NFTs held by each address
    mapping(address => uint256) public totalNFTsHeld;

    // Owner's share mapping
    mapping(address => uint256) public ownerShares;

    // Referral mapping: referrer => referee
    mapping(address => address[]) public referrals;

    // Mapping to track the number of NFTs minted by each address using a referral code
    mapping(address => uint256) public mintedWithReferral;

    // Address of the Psycho Gems ERC20 token contract
    address public psychoGemsToken;

    // Event to log referral rewards
    event ReferralReward(address indexed referrer, address indexed referee, uint256 tokens);

    // New variables for presale logic
    mapping(address => uint256) public presaleMintsPerWallet;
    uint256 public constant PRESALE_FREE_LIMIT = 300;
    uint256 public totalFreeMints;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // Initialize the contract with the address of the Psycho Gems ERC20 token contract
    function initialize(address initialOwner, address _psychoGemsToken) initializer public {
        __ERC721_init("PsychoChibis", "PSYCHO");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __Ownable_init(initialOwner);
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        // Move initial value assignments to the constructor or initializers
        baseExtension = ".json";
        presaleCost = 2150 ether;
        regularCost = 3550 ether;
        maxSupply = 1568;
        maxMintAmount = 10;
        revealed = false;
        baseURI = "ipfs://bafybeidjgv5osvyogglerak62of77onccyss5neb2xocklwhgjozl5ne4u/"; // Replace with your URI
        notRevealedUri = ""; // Replace with your URI
        presaleActive = true;
        nftholderRewardPercentage = 15;
        psychoGemsToken = _psychoGemsToken; // Set the address of the Psycho Gems ERC20 token contract
        nonce = 0;
        totalFreeMints = 0;
        

    }

    // Constants for allocation percentages
    uint256 private constant OWNER_PERCENTAGE = 60;
    uint256 private constant DELEGATION_PERCENTAGE = 7;
    uint256 private constant LP_PERCENTAGE = 7;

    function mintWithReferral(uint256 _mintAmount, address referralCode) public payable nonReentrant returns (bool) {
    uint256 supply = totalSupply();
    require(!paused(), "Minting is currently paused");
    require(_mintAmount > 0, "Mint amount must be greater than 0");
    require(_mintAmount <= maxMintAmount, "Mint amount exceeds the maximum allowed");
    require(supply + _mintAmount <= maxSupply, "Minting would exceed the maximum supply");
    uint256 cost = presaleActive ? presaleCost : regularCost;
    if (msg.sender != owner()) {
        require(msg.value >= cost * _mintAmount, "Insufficient payment for minting");

        uint256 ownersShare = (cost * OWNER_PERCENTAGE * _mintAmount) / 100;
        uint256 nftholderReward = (cost * nftholderRewardPercentage * _mintAmount) / 100;
        uint256 delegation = (cost * DELEGATION_PERCENTAGE * _mintAmount) / 100;
        uint256 lp = (cost * LP_PERCENTAGE * _mintAmount) / 100;

        ownerShares[owner()] += ownersShare;
        distributeRewards(nftholderReward);

        // Update the accumulated funds
        totalDelegationFunds += delegation;
        totalLPFunds += lp;

        if (referralCode != address(0) && referralCode != msg.sender) {
       referrals[referralCode].push(msg.sender);
                mintedWithReferral[msg.sender] += _mintAmount;

                uint256 referrerReward = 350 ether * _mintAmount;
                 uint256 refereeReward = 350 ether * _mintAmount;  // Reward for the referee (updated calculation)
                payable(referralCode).transfer(referrerReward);
                IERC20(psychoGemsToken).transfer(msg.sender, refereeReward);

                emit ReferralReward(referralCode, msg.sender, refereeReward);

            }
        }

       for (uint256 i = 0; i < _mintAmount; i++) {
    uint256 randTokenId = randomTokenId();
    while (mintedTokenIds[randTokenId]) {
        randTokenId = randomTokenId();
    }
    _safeMint(msg.sender, randTokenId);
    mintedTokenIds[randTokenId] = true;

    // Construct and set the token URI for the minted token
    string memory newTokenURI = string(abi.encodePacked(baseURI, uint256ToString(randTokenId), baseExtension));
    _setTokenURI(randTokenId, newTokenURI);
}
    return true;
    }

    function randomTokenId() internal returns (uint256) {
    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % maxSupply;
    nonce++;
    return rand;
    
}

// Function to mint tokens directly to a specified address

function mintToAddress(uint256 _mintAmount, address _recipient) public onlyOwner nonReentrant returns (bool) {
    require(_mintAmount > 0, "Mint amount must be greater than 0");
    require(_recipient != address(0), "Recipient address cannot be the zero address");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "Minting would exceed the maximum supply");

    for (uint256 i = 0; i < _mintAmount; i++) {
        uint256 randTokenId = randomTokenId();
        while (mintedTokenIds[randTokenId]) {
            randTokenId = randomTokenId();
        }
        _safeMint(_recipient, randTokenId);
        mintedTokenIds[randTokenId] = true;

        // Construct and set the token URI for the minted token
        string memory newTokenURI = string(abi.encodePacked(baseURI, uint256ToString(randTokenId), baseExtension));
        _setTokenURI(randTokenId, newTokenURI);
    }
    return true;
}



        // Function to set the presale cost, only callable by the owner
    function setPresaleCost(uint256 _newPresaleCost) public onlyOwner {
        presaleCost = _newPresaleCost;
    }

    // Function to set the regular cost, only callable by the owner
    function setRegularCost(uint256 _newRegularCost) public onlyOwner {
        regularCost = _newRegularCost;
    }

    // Function to get the total delegation funds
    function getTotalDelegationFunds() public view returns (uint256) {
        return totalDelegationFunds;
    }

    // Function to get the total LP funds
    function getTotalLPFunds() public view returns (uint256) {
        return totalLPFunds;
    }


    // Function to withdraw delegation funds, restricted to the owner
    function withdrawDelegationFunds(uint256 amount) public onlyOwner nonReentrant {
        require(amount <= totalDelegationFunds, "Amount exceeds available delegation funds");
        totalDelegationFunds -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Function to withdraw LP funds, restricted to the owner
    function withdrawLPFunds(uint256 amount) public onlyOwner nonReentrant {
        require(amount <= totalLPFunds, "Amount exceeds available LP funds");
        totalLPFunds -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Function to distribute rewards based on NFT holdings
function distributeRewards(uint256 totalReward) private {
    uint256 totalNFTs = totalSupply();
    for (uint256 i = 0; i < totalNFTs; i++) {
        address holder = ownerOf(tokenByIndex(i));
        uint256 holderShare = (totalReward * balanceOf(holder)) / totalNFTs;
        nftholderRewards[holder] += holderShare;
    }
}

    // Function to claim NFTholder rewards
    function claimRewards() public nonReentrant {
        require(nftholderRewards[msg.sender] > 0, "No rewards to claim");
        uint256 rewards = nftholderRewards[msg.sender];
        nftholderRewards[msg.sender] = 0;
        payable(msg.sender).transfer(rewards);
    }

    // Function to withdraw the owner's share
    function withdrawOwnerShare() public onlyOwner nonReentrant {
        require(ownerShares[owner()] > 0, "No owner's share to withdraw");
        uint256 share = ownerShares[owner()];
        ownerShares[owner()] = 0;
        payable(owner()).transfer(share);
    }

   // Emergency withdrawal function for specified amount
function emergencyWithdraw(uint256 amount) public onlyOwner nonReentrant {
    uint256 contractBalance = address(this).balance;
    require(contractBalance >= amount, "Insufficient funds for withdrawal");
    require(amount > 0, "Withdrawal amount must be greater than zero");

    payable(owner()).transfer(amount);
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



    // Helper function to convert uint256 to string
function uint256ToString(uint256 value) internal pure returns (string memory) {
    // Code to convert uint256 to string
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}


    function version() pure public returns (string memory) {
        return "v1!";
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

    function setBaseURI(string memory newBaseURI) public onlyOwner {
    baseURI = newBaseURI;
}

// Function to set the token URI for a given token
function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
    require(ownerOf(tokenId) != address(0), "ERC721URIStorage: URI set of nonexistent token");

    // Construct the full URI
    string memory fullURI = string(abi.encodePacked(_tokenURI, uint256ToString(tokenId), ".json"));
    _setTokenURI(tokenId, fullURI);
}



}
