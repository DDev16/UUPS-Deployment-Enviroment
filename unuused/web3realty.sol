// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RealEstateToken is Initializable, ERC1155Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 private _currentTokenID;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public propertyShares;

    function initialize(address _initialOwner) public initializer {
        __ERC1155_init("https://api.realestate.com/tokens/");
        __Ownable_init(_initialOwner);
        _currentTokenID = 1; // Set the initial value in the initializer
    }

    function mintProperty(address to, uint256 shares, string memory tokenURI) public onlyOwner {
        uint256 newItemId = _currentTokenID++;
        _tokenURIs[newItemId] = tokenURI;
        _mint(to, newItemId, 1, ""); // Mint the property as an NFT
        _mint(to, newItemId, shares, ""); // Mint the shares as fungible tokens
        emit PropertyMinted(newItemId, to, shares, tokenURI);
    }

    function setTokenURI(uint256 tokenId, string memory newURI) public onlyOwner {
        require(bytes(_tokenURIs[tokenId]).length > 0, "Token ID does not exist");
        _tokenURIs[tokenId] = newURI;
        emit TokenURIUpdated(tokenId, newURI);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(bytes(_tokenURIs[tokenId]).length > 0, "Token ID does not exist");
        return _tokenURIs[tokenId];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    event PropertyMinted(uint256 indexed propertyId, address indexed owner, uint256 shares, string tokenURI);
    event TokenURIUpdated(uint256 indexed tokenId, string newURI);
}
