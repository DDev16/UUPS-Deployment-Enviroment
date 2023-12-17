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

// Import the interface for the ERC20 token
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTV3 is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, ERC721PausableUpgradeable, OwnableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {

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

    // Referral mapping: referrer => referee
    mapping(address => address[]) public referrals;

    // Mapping to track the number of NFTs minted by each address using a referral code
    mapping(address => uint256) public mintedWithReferral;

    // Address of the Psycho Gems ERC20 token contract
    address public psychoGemsToken;

    // Event to log referral rewards
    event ReferralReward(address indexed referrer, address indexed referee, uint256 tokens);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // Initialize the contract with the address of the Psycho Gems ERC20 token contract
    function initialize(address initialOwner, address _psychoGemsToken) initializer public {
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
        psychoGemsToken = _psychoGemsToken; // Set the address of the Psycho Gems ERC20 token contract
    }

      // Function to set the address of the Psycho Gems ERC20 token contract, only callable by the owner
    function setPsychoGemsToken(address _newPsychoGemsToken) public onlyOwner {
        psychoGemsToken = _newPsychoGemsToken;
    }


    // Function to mint NFTs with a referral code
    function mintWithReferral(uint256 _mintAmount, address referralCode) public payable nonReentrant {
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
            ownerShares[owner()] += msg.value - nftholderReward;

            // Check if the referral code is valid (not the minter's address)
            if (referralCode != address(0) && referralCode != msg.sender) {
                referrals[referralCode].push(msg.sender);
                mintedWithReferral[msg.sender] += _mintAmount;

                // Reward the referrer with 15 ether and the referee with deposited tokens per NFT
                uint256 referrerReward = 15 ether * _mintAmount;
                uint256 refereeReward = IERC20(psychoGemsToken).balanceOf(address(this)) * _mintAmount; // Use deposited tokens as rewards
                payable(referralCode).transfer(referrerReward);
                IERC20(psychoGemsToken).transfer(msg.sender, refereeReward); // Transfer tokens to the referee

                emit ReferralReward(referralCode, msg.sender, refereeReward);
            }
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
        return "v3!";
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

    // Function to set the presale cost, only callable by the owner
function setPresaleCost(uint256 _newPresaleCost) public onlyOwner {
    presaleCost = _newPresaleCost;
}

// Function to set the regular cost, only callable by the owner
function setRegularCost(uint256 _newRegularCost) public onlyOwner {
    regularCost = _newRegularCost;
}

}
