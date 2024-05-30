// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyToken is Initializable, ERC1155Upgradeable, AccessControlUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 private _currentTokenID;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public propertyShares;
    mapping(uint256 => uint256) public sharePrice;  // Price per share for each property
    mapping(uint256 => uint256) public rentalIncome;
    mapping(uint256 => address) public propertyOwner;  // Tracks the owner of each property

    event PropertyMinted(uint256 indexed propertyId, address indexed owner, uint256 shares, uint256 pricePerShare);
    event TokenURIUpdated(uint256 indexed tokenId, string newURI);
    event SharePriceSet(uint256 indexed tokenId, uint256 price);
    event SharesListed(uint256 indexed tokenId, bool listed);
    event SharesBought(address indexed buyer, address indexed seller, uint256 tokenId, uint256 shares, uint256 pricePerShare);
    event SharesSold(address indexed seller, uint256 tokenId, uint256 shares);
    event RentalPaymentReceived(uint256 tokenId, uint256 amount);
    event DividendDistributed(address indexed shareholder, uint256 tokenId, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin)
        initializer public
    {
        __ERC1155_init("https://api.realestate.com/tokens/");
        __AccessControl_init();
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(URI_SETTER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(TREASURER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _currentTokenID = 1;  // Set the initial value in the initializer
    }

    function mintProperty(uint256 shares, uint256 price, string memory uri) public {
        uint256 newItemId = _currentTokenID++;
        _mint(msg.sender, newItemId, shares, "");
        _tokenURIs[newItemId] = uri;
        propertyShares[newItemId] = shares;
        sharePrice[newItemId] = price;
        propertyOwner[newItemId] = msg.sender;  // Set the property owner

        emit PropertyMinted(newItemId, msg.sender, shares, price);
        emit TokenURIUpdated(newItemId, uri);
    }

    function listShares(uint256 tokenId, bool listed) public {
        require(msg.sender == propertyOwner[tokenId], "Only the property owner can list shares.");
        sharePrice[tokenId] = sharePrice[tokenId];  // Confirm the share price
        emit SharesListed(tokenId, listed);
    }

    function buyShares(uint256 tokenId, uint256 shares) public payable {
        require(sharePrice[tokenId] > 0, "Shares not listed for sale.");
        require(msg.value == shares * sharePrice[tokenId], "Incorrect Ether amount sent.");
        address seller = propertyOwner[tokenId];
        require(seller != msg.sender, "Cannot buy shares from yourself.");

        _safeTransferFrom(seller, msg.sender, tokenId, shares, "");
        payable(seller).transfer(msg.value);
        emit SharesBought(msg.sender, seller, tokenId, shares, sharePrice[tokenId]);
    }

    function receiveRentalPayment(uint256 tokenId) public payable {
        require(propertyShares[tokenId] > 0, "No shares issued for this token.");
        rentalIncome[tokenId] += msg.value;
        emit RentalPaymentReceived(tokenId, msg.value);
    }

    function distributeDividends(uint256 tokenId) public {
        require(msg.sender == propertyOwner[tokenId], "Only the owner can distribute dividends.");
        uint256 totalDividend = rentalIncome[tokenId];
        require(totalDividend > 0, "No rental income to distribute.");

        uint256 totalShares = propertyShares[tokenId];
        uint256 dividendPerShare = totalDividend / totalShares;

        // Assumes the property owner distributes dividends fairly
        for (uint256 i = 0; i < totalShares; i++) {
            address holder = propertyOwner[tokenId];
            payable(holder).transfer(dividendPerShare * balanceOf(holder, tokenId));
            emit DividendDistributed(holder, tokenId, dividendPerShare * balanceOf(holder, tokenId));
        }

        rentalIncome[tokenId] = 0;  // Reset rental income after distribution
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

   

     // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
