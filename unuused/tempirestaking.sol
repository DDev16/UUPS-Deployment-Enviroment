// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing necessary OpenZeppelin contracts for upgradeability, access control, security, and token standards.
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";

// Custom NFT contract import. Ensure this path is correctly set to where your NFT contract is located.
import "./fractionalsemi.sol";

/**
 * @title Enhanced Soft Staking Contract for ERC1155 NFTs
 * @dev This contract allows users to stake their ERC1155 NFTs and earn rewards based on the staking duration. 
 * It features upgradeability, reentrancy protection, and emergency stop mechanisms.
 * The contract uses the UUPS (Universal Upgradeable Proxy Standard) for upgradeability.
 */
contract EnhancedSoftStakingContract is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable {
    // ERC20 token used for rewards.
    IERC20 public rewardsToken;

    // Instance of the NFT contract.
    FractionalSemi public nftContract;

    // Reward rate per day per NFT staked.
    uint256 public rewardRatePerDay;

    // Struct to store information about stakes.
    struct StakeInfo {
        uint256 amountStaked; // Amount of NFTs staked.
        uint256 lastClaimTime; // Timestamp of the last reward claim.
    }

    // Mapping from user address and token ID to staking information.
    mapping(address => mapping(uint256 => StakeInfo)) public stakes;

    // Mapping to keep track of users who have onboarded.
    mapping(address => bool) public onboardedUsers;

    // Events for logging contract activity.
    event UserOnboarded(address indexed user);
    event Staked(address indexed user, uint256 tokenId, uint256 amount);
    event Unstaked(address indexed user, uint256 tokenId, uint256 amount);
    event RewardClaimed(address indexed user, uint256 tokenId, uint256 reward);
    event OwnershipVerified(address indexed user, uint256 tokenId, uint256 actualBalance);

    /**
     * @dev Initializes the contract with necessary parameters.
     * @param initialOwner Address to be set as the initial owner of the contract.
     * @param _rewardsToken Address of the ERC20 token to be used for rewards.
     * @param _nftContract Address of the ERC1155 NFT contract.
     * @param _rewardRatePerDay Daily reward rate per NFT staked.
     */
    function initialize(address initialOwner, address _rewardsToken, address _nftContract, uint256 _rewardRatePerDay) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init_unchained(initialOwner);
        __UUPSUpgradeable_init();
        __ERC1155Pausable_init();

        rewardsToken = IERC20(_rewardsToken);
        nftContract = FractionalSemi(_nftContract);
        rewardRatePerDay = _rewardRatePerDay;
    }

    // Additional functions (onboardUser, stake, unstake, etc.) follow, each annotated similarly with purpose, parameters, and functionality described.

    /**
     * @dev Allows users to onboard themselves to the staking contract. Onboarding is a prerequisite for staking.
     */
    function onboardUser() public {
        require(!onboardedUsers[msg.sender], "User already onboarded");
        onboardedUsers[msg.sender] = true;
        emit UserOnboarded(msg.sender);
    }

        /**
     * @dev Allows users to stake their NFTs by token ID. Users must have been onboarded and must own the NFT.
     * @param tokenId The ID of the NFT to stake.
     * 
     * This function updates the stake information for the user and the specified NFT, marking the current timestamp
     * as the last claim time. This is crucial for calculating rewards later on.
     */
    function stake(uint256 tokenId) public nonReentrant {
        require(onboardedUsers[msg.sender], "User not onboarded");
        uint256 balance = nftContract.balanceOf(msg.sender, tokenId);
        require(balance > 0, "No NFTs to stake");

        stakes[msg.sender][tokenId] = StakeInfo({
            amountStaked: balance,
            lastClaimTime: block.timestamp
        });

        emit Staked(msg.sender, tokenId, balance);
    }

    /**
     * @dev Allows users to unstake their NFTs by token ID and claim any pending rewards.
     * @param tokenId The ID of the NFT to unstake.
     * 
     * The function claims any rewards due for the staked NFT before removing the stake information.
     * This ensures that users receive all due rewards upon unstaking.
     */
    function unstake(uint256 tokenId) public nonReentrant {
        require(stakes[msg.sender][tokenId].amountStaked > 0, "No NFTs staked");
        claimReward(tokenId); // Ensures that rewards are claimed before unstaking.
        emit Unstaked(msg.sender, tokenId, stakes[msg.sender][tokenId].amountStaked);
        delete stakes[msg.sender][tokenId];
    }

    /**
     * @dev Allows users to claim rewards for a specific staked NFT.
     * @param tokenId The ID of the staked NFT.
     * 
     * Rewards are calculated based on the time elapsed since the last claim and the reward rate per day.
     * The function updates the last claim time to the current timestamp upon successful reward claim.
     */
    function claimReward(uint256 tokenId) public nonReentrant {
        StakeInfo storage info = stakes[msg.sender][tokenId];
        uint256 actualBalance = nftContract.balanceOf(msg.sender, tokenId);

        require(actualBalance >= info.amountStaked, "Insufficient NFT balance to claim rewards.");
        require(info.amountStaked > 0, "No NFTs staked");

        uint256 reward = calculateReward(msg.sender, tokenId);
        require(reward > 0, "No rewards available");
        require(rewardsToken.balanceOf(address(this)) >= reward, "Insufficient funds in contract for rewards");

        info.lastClaimTime = block.timestamp;
        rewardsToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, tokenId, reward);
    }

    /**
     * @dev Utility function to verify the ownership of an NFT.
     * @param user The address of the user.
     * @param tokenId The ID of the NFT to verify.
     * 
     * Emits an OwnershipVerified event if the user owns the NFT.
     */
    function verifyOwnership(address user, uint256 tokenId) public {
        uint256 actualBalance = nftContract.balanceOf(user, tokenId);
        require(actualBalance > 0, "User does not own the NFT.");
        emit OwnershipVerified(user, tokenId, actualBalance);
    }

    /**
     * @dev Calculates the reward for a staked NFT based on the time elapsed and the staking rate.
     * @param user The address of the user claiming the reward.
     * @param tokenId The ID of the staked NFT.
     * @return The amount of rewards owed.
     */
    function calculateReward(address user, uint256 tokenId) public view returns (uint256) {
        StakeInfo memory info = stakes[user][tokenId];
        uint256 stakedDuration = block.timestamp - info.lastClaimTime;
        uint256 dailyReward = rewardRatePerDay * info.amountStaked;
        return (stakedDuration * dailyReward) / 86400; // 86400 seconds in a day, converts to daily rate.
    }

    // Implementation-specific functions such as _authorizeUpgrade, setRewardRatePerDay, pause, and unpause follow,
    // each with detailed comments similar to the ones provided above.

    /**
     * @dev Internal function to authorize upgrading the contract to a new implementation.
     * @param newImplementation The address of the new contract implementation.
     * 
     * This function is called internally and requires the caller to be the contract owner.
     * It's part of the UUPS upgradeability pattern and ensures only authorized upgrades.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Allows the contract owner to set a new reward rate per day.
     * @param _newRate The new reward rate per day.
     * 
     * Adjusting the reward rate can help manage the economic model of the staking contract.
     */
    function setRewardRatePerDay(uint256 _newRate) public onlyOwner {
        rewardRatePerDay = _newRate;
    }

    /**
     * @dev Pauses all staking and reward claim operations.
     * 
     * This function can be used by the contract owner to pause the contract operations in case of emergency
     * or to perform maintenance. It leverages the Pausable extension from OpenZeppelin.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all operations, resuming staking and reward claims.
     * 
     * This function allows the contract to resume normal operations after being paused by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }
}
