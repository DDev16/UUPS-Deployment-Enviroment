// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract ChaoticCreationsStaking is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC20 public rewardsToken;
    ERC721EnumerableUpgradeable public nftCollection;
    uint256 public rewardPerSecond; // Common reward for all NFTs
    mapping(address => uint256) public lastClaimed;

    struct Tier {
        uint256 minNFTs;
        uint256 rewardMultiplier;
    }

    Tier[] public tiers;

    event RewardClaimed(address indexed user, uint256 amount);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event UserOnboarded(address indexed user);
    event TierUpdated(uint256 tierIndex, uint256 minNFTs, uint256 rewardMultiplier);

   function initialize(IERC20 _rewardsToken, ERC721EnumerableUpgradeable _nftCollection, address initialOwner) public initializer {
    __Ownable_init(initialOwner); // Pass the initial owner address
    rewardsToken = _rewardsToken;
    nftCollection = _nftCollection;

        // Initialize tiers
        tiers.push(Tier(1, 1));  // Bronze
        tiers.push(Tier(6, 2));  // Silver
        tiers.push(Tier(11, 3)); // Gold
        tiers.push(Tier(16, 4)); // Diamond
        tiers.push(Tier(21, 5)); // Psycho
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setRewardPerSecond(uint256 _rewardPerSecond) external onlyOwner {
        rewardPerSecond = _rewardPerSecond;
    }

    function onBoardUser() external {
        uint256 balance = nftCollection.balanceOf(msg.sender);
        require(balance > 0, "User must have at least one NFT");
        require(lastClaimed[msg.sender] == 0, "User has already been onboarded");

        lastClaimed[msg.sender] = block.timestamp;
        emit UserOnboarded(msg.sender);
    }

    function claimRewards() external {
        uint256 balance = nftCollection.balanceOf(msg.sender);
        require(balance > 0, "No NFTs to claim rewards for");

        uint256 tierIndex = determineTier(msg.sender);
        uint256 rewardMultiplier = tiers[tierIndex].rewardMultiplier;

        uint256 timeElapsed = block.timestamp - lastClaimed[msg.sender];
        uint256 rewards = rewardPerSecond * timeElapsed * balance * rewardMultiplier;

        require(rewardsToken.balanceOf(address(this)) >= rewards, "Not enough tokens in the contract");

        lastClaimed[msg.sender] = block.timestamp;
        rewardsToken.transfer(msg.sender, rewards);

        emit RewardClaimed(msg.sender, rewards);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        rewardsToken.transferFrom(msg.sender, address(this), amount);
        emit TokensDeposited(msg.sender, amount);
    }

    function withdrawRewards(uint256 amount) external onlyOwner {
        require(rewardsToken.balanceOf(address(this)) >= amount, "Not enough tokens in the contract");
        rewardsToken.transfer(msg.sender, amount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    function getNFTBalance(address user) public view returns (uint256) {
        return nftCollection.balanceOf(user);
    }

    function getPendingRewards(address user) public view returns (uint256) {
        if (lastClaimed[user] == 0 || nftCollection.balanceOf(user) == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastClaimed[user];
        return rewardPerSecond * timeElapsed * nftCollection.balanceOf(user);
    }

    function getOnboardedStatus(address user) public view returns (bool) {
        return lastClaimed[user] != 0;
    }

    // Function to determine the user's tier based on the number of NFTs
   function determineTier(address user) public view returns (uint256) {
    uint256 balance = nftCollection.balanceOf(user);

    if (balance < 1) {
        return 0; // No NFTs
    }
    if (balance >= 1 && balance < 6) {
        return 1; // Tier 1
    }
    if (balance >= 6 && balance < 11) {
        return 2; // Tier 2
    }
    if (balance >= 11 && balance < 16) {
        return 3; // Tier 3
    }
    if (balance >= 16 && balance < 21) {
        return 4; // Tier 4
    }
    return 5; // Tier 5 and beyond
}


    // Function to update tier parameters (onlyOwner for security)
    function updateTier(uint256 tierIndex, uint256 minNFTs, uint256 rewardMultiplier) external onlyOwner {
        require(tierIndex < tiers.length, "Invalid tier index");
        tiers[tierIndex] = Tier(minNFTs, rewardMultiplier);
        emit TierUpdated(tierIndex, minNFTs, rewardMultiplier);
    }
}
