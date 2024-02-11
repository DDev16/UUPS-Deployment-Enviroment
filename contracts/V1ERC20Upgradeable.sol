// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PsychoGems is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable // Inherit ReentrancyGuardUpgradeable
{
    uint256 private constant TOKENS_PER_CLAIM = 5 * 10 ** 18;
    uint256 private constant CLAIM_INTERVAL = 1 days;
    uint256 private constant WEEKLY_PAY = 1000 * 10 ** 18;
    uint256 private constant WEEK = 1 weeks;
    uint256 public presaleMintedCount;


    mapping(address => uint256) private lastClaimTimes;
    mapping(address => uint256) private lastPayTime;

    event WeeklyPayClaimed(address indexed claimant, uint256 amount);

    event TeamMemberAdded(address indexed newMember);
    event TeamMemberRemoved(address indexed removedMember);
    address[] private teamMembers;

    

    function initialize(address initialOwner) public initializer {
        __ERC20_init("PsychoGems", "PSYGEM");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("PsychoGems");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000 * 10 ** decimals());
        __ReentrancyGuard_init(); // Initialize the ReentrancyGuard

    }

    // Minting function allows the owner to create new tokens and assign them to a specific address.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function claimTokens() public nonReentrant {
        require(
            block.timestamp - lastClaimTimes[msg.sender] >= CLAIM_INTERVAL,
            "Claim interval not reached"
        );

        _mint(msg.sender, TOKENS_PER_CLAIM);
        lastClaimTimes[msg.sender] = block.timestamp;
    }

    // A function for transferring ownership of the contract.
    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }

    // Pause and unpause the token transfers, useful for emergency situations.
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function version() public pure returns (string memory) {
        return "v2!";
    }

    // Override the upgrade authorization function to allow only the owner to upgrade.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // The following functions are overrides required by Solidity.
    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(
            ERC20Upgradeable,
            ERC20PausableUpgradeable,
            ERC20VotesUpgradeable
        )
    {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    )
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function claimWeeklyPay() external nonReentrant {
        require(isTeamMember(msg.sender), "Not a team member");
        require(
            block.timestamp - lastPayTime[msg.sender] >= WEEK,
            "Week not passed"
        );

        _mint(msg.sender, WEEKLY_PAY);
        lastPayTime[msg.sender] = block.timestamp;

        emit WeeklyPayClaimed(msg.sender, WEEKLY_PAY);
    }
    

    // Function to safely check if an address is a team member
    function isTeamMember(address account) public view returns (bool) {
        for (uint256 i = 0; i < teamMembers.length; i++) {
            if (teamMembers[i] == account) {
                return true;
            }
        }
        return false;
    }

   

    /**
     * @dev Distributes the weekly pay to all team members. Can be called by the owner multiple times.
     */
    function distributeWeeklyPayment() public onlyOwner {
        for (uint i = 0; i < teamMembers.length; i++) {
            // Optionally, add logic to check if a payment is due or missed for a particular member.
            // This example simply mints the weekly pay to each team member without checks.
            _mint(teamMembers[i], WEEKLY_PAY);
            // Update the lastPayTime to the current timestamp.
            lastPayTime[teamMembers[i]] = block.timestamp;
            emit WeeklyPayClaimed(teamMembers[i], WEEKLY_PAY);
        }
    }

    // Improved addTeamMember with event logging
    function addTeamMember(address _newMember) public onlyOwner {
        require(!isTeamMember(_newMember), "Address is already a team member");
        teamMembers.push(_newMember);
        emit TeamMemberAdded(_newMember); // Log the addition
    }

    // Improved removeTeamMember with event logging
    function removeTeamMember(address _member) public onlyOwner {
        require(isTeamMember(_member), "Address is not a team member");
        for (uint256 i = 0; i < teamMembers.length; i++) {
            if (teamMembers[i] == _member) {
                teamMembers[i] = teamMembers[teamMembers.length - 1];
                teamMembers.pop();
                emit TeamMemberRemoved(_member); // Log the removal
                return;
            }
        }
    }

    
    // Optional: Getter for the teamMembers array for debugging
    function getTeamMembers() public view returns (address[] memory) {
        return teamMembers;
    }
}
