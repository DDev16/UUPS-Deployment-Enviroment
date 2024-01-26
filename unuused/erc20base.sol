// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ERC20V1 is  Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, UUPSUpgradeable {
     

      // Constants for the claim functionality
    uint256 private constant TOKENS_PER_CLAIM = 250 * 10**18; // 250 tokens per claim
    uint256 private constant CLAIM_INTERVAL = 1 days;

    // Mapping to keep track of last claim times
    mapping(address => uint256) private lastClaimTimes;

    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC20_init("Version2", "V1");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("Version2");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    // Minting function allows the owner to create new tokens and assign them to a specific address.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

         function claimTokens() public {
        require(block.timestamp - lastClaimTimes[msg.sender] >= CLAIM_INTERVAL, "Claim interval not reached");
        require(balanceOf(address(this)) >= TOKENS_PER_CLAIM, "Insufficient tokens in contract");
        lastClaimTimes[msg.sender] = block.timestamp;
        _transfer(address(this), msg.sender, TOKENS_PER_CLAIM);
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


    function version() pure public returns (string memory) {
        return "v2!";
    }

    // Override the upgrade authorization function to allow only the owner to upgrade.
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value) internal override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20PermitUpgradeable, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }





}
