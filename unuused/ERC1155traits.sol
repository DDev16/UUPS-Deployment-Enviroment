// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC721Factory.sol"; // Import the ERC721 contract

contract ChibiFactoryTraits is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    // Mapping from trait ID to ERC20 token address
    mapping(uint256 => IERC20) public traitToERC20Token;
    IERC20 public paymentToken; // Your custom ERC20 token
    ChibiFactoryNFTs public chibiFactoryNFTs;

    struct TokenData {
        string name;
        string uri;
        uint256 totalSupply;
        uint256 price;
    }

     struct Listing {
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
    }

    uint256 private _currentListingId;
    mapping(uint256 => Listing) public listings;

    event TokenListed(uint256 indexed listingId, address indexed seller, uint256 indexed tokenId, uint256 amount, uint256 price);
    event TokenSold(uint256 indexed listingId, address indexed buyer, uint256 indexed tokenId, uint256 amount);
    event ListingCancelled(uint256 indexed listingId);
    mapping(uint256 => mapping(address => uint256)) private lockedTraits;

    mapping(uint256 => uint256) private initialTotalSupplies;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => uint256) private traitPrices;
    mapping(uint256 => string) private tokenNames; // Mapping for token names

    event OwnershipTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
    }

    function setTokenName(uint256 _id, string memory _name) public onlyOwner {
        tokenNames[_id] = _name;
    }

    function getTokenName(uint256 _id) public view returns (string memory) {
        return tokenNames[_id];
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setTraitERC20Token(uint256 _traitId, address _erc20Address) external onlyOwner {
        traitToERC20Token[_traitId] = IERC20(_erc20Address);
    }

    function mint(address _to, uint _id, uint _amount) external onlyOwner {
        _mint(_to, _id, _amount, "");
        emit OwnershipTransferred(_id, address(0), _to);
    }

    function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
        _mintBatch(_to, _ids, _amounts, "");
        emit OwnershipTransferred(_ids[0], address(0), _to);
    }

    function burn(uint _id, uint _amount)  external {
        _burn(msg.sender, _id, _amount);
        emit OwnershipTransferred(_id, msg.sender, address(0));
    }

    function batchBurn(uint[] memory _ids, uint[] memory _amounts) external {
        _burnBatch(msg.sender, _ids, _amounts);
        emit OwnershipTransferred(_ids[0], msg.sender, address(0));
    }

    function purchaseTrait(uint256 traitId, uint256 amount) public {
        require(traitToERC20Token[traitId] != IERC20(address(0)), "ERC20 token not set for trait");
        require(initialTotalSupplies[traitId] > 0, "Trait not initialized");
        require(totalSupply(traitId) + amount <= initialTotalSupplies[traitId], "Exceeds available trait supply");

        IERC20 erc20Token = traitToERC20Token[traitId];
        uint256 price = getTraitPrice(traitId);
        uint256 totalPrice = price * amount;

        require(erc20Token.balanceOf(msg.sender) >= totalPrice, "Insufficient ERC20 balance");
        erc20Token.transferFrom(msg.sender, address(this), totalPrice);

        _mint(msg.sender, traitId, amount, "");
        emit OwnershipTransferred(traitId, address(0), msg.sender);
    }

    function setTraitPrice(uint256 traitId, uint256 price) external onlyOwner {
        traitPrices[traitId] = price;
    }

    function getTraitPrice(uint256 traitId) public view returns (uint256) {
        return traitPrices[traitId];
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function getTokenData(uint256 _id) public view returns (TokenData memory) {
        return TokenData({
            name: tokenNames[_id],
            uri: uri(_id),
            totalSupply: totalSupply(_id),
            price: traitPrices[_id]
        });
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable) {
        super._update(from, to, ids, values);
        emit OwnershipTransferred(ids[0], from, to);
    }

    function setTokenURI(uint256 _id, string memory _uri) public onlyOwner {
        tokenURIs[_id] = _uri;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURIs[_id];
    }

    function setInitialTotalSupply(uint256 _id, uint256 _totalSupply) public onlyOwner {
        require(initialTotalSupplies[_id] == 0, "Initial total supply already set");
        initialTotalSupplies[_id] = _totalSupply;
    }

    function getInitialTotalSupply(uint256 _id) public view returns (uint256) {
        return initialTotalSupplies[_id];
    }

      function setPaymentToken(address _paymentTokenAddress) external onlyOwner {
        paymentToken = IERC20(_paymentTokenAddress);
    }

    function listTokenForSale(uint256 tokenId, uint256 amount, uint256 price) public {
    require(chibiFactoryNFTs.isTraitAvailableForListing(tokenId), "Trait is currently in use by an NFT");
    
        require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient token balance");
        _safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        uint256 listingId = _currentListingId++;
        listings[listingId] = Listing(msg.sender, tokenId, amount, price);
        emit TokenListed(listingId, msg.sender, tokenId, amount, price);
    }

    function buyToken(uint256 listingId) public {
        Listing memory listing = listings[listingId];
        require(listing.amount > 0, "Listing does not exist");
        require(paymentToken.balanceOf(msg.sender) >= listing.price, "Insufficient token balance");

        paymentToken.transferFrom(msg.sender, listing.seller, listing.price);
        _safeTransferFrom(address(this), msg.sender, listing.tokenId, listing.amount, "");

        emit TokenSold(listingId, msg.sender, listing.tokenId, listing.amount);
        delete listings[listingId];
    }

    function cancelListing(uint256 listingId) public {
        Listing memory listing = listings[listingId];
        require(msg.sender == listing.seller, "Only seller can cancel listing");
        _safeTransferFrom(address(this), listing.seller, listing.tokenId, listing.amount, "");
        emit ListingCancelled(listingId);
        delete listings[listingId];
    }

    
    
}
