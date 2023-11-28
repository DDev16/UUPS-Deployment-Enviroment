// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract SpaceKittyNFTStaking12 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC20Upgradeable public rewardsToken;
    ERC721EnumerableUpgradeable public nftCollection;
    uint256 public rewardPerSecond; // Common reward for all NFTs
    mapping(address => uint256) public lastClaimed;

    event RewardClaimed(address indexed user, uint256 amount);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event UserOnboarded(address indexed user);

    function initialize(IERC20Upgradeable _rewardsToken, ERC721EnumerableUpgradeable _nftCollection) public initializer {
        __Ownable_init();
        rewardsToken = _rewardsToken;
        nftCollection = _nftCollection;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setRewardPerSecond(uint256 _rewardPerSecond) external onlyOwner {
        rewardPerSecond = _rewardPerSecond;
    }

    function onBoardUser() external {
        require(nftCollection.balanceOf(msg.sender) > 0, "User must have at least one NFT");
        require(lastClaimed[msg.sender] == 0, "User has already been onboarded");

        lastClaimed[msg.sender] = block.timestamp;
        emit UserOnboarded(msg.sender);
    }

    function claimRewards() external {
        uint256 balance = nftCollection.balanceOf(msg.sender);
        require(balance > 0, "No NFTs to claim rewards for");

        uint256 rewards = 0;
        uint256 timeElapsed = block.timestamp - lastClaimed[msg.sender];

        rewards = rewardPerSecond * timeElapsed * balance;

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
        if (lastClaimed[user] == 0) {
            return 0;
        }

        uint256 balance = nftCollection.balanceOf(user);
        if (balance == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastClaimed[user];
        return rewardPerSecond * timeElapsed * balance;
    }
    
    function getOnboardedStatus(address user) public view returns (bool) {
        return lastClaimed[user] != 0;
    }
}
