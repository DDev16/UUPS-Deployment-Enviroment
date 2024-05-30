// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MarketingTesting is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    // Mapping from token ID to metadata URIs
    mapping(uint256 => string) private _tokenURIs;
    
    // Name of the contract or collection
    string private _name;

    // Event to emit when a token is minted with its URI
    event TokenMintedWithURI(address indexed account, uint256 indexed id, uint256 amount, string tokenURI);

    function initialize(string memory name, address initialOwner) public initializer {
        __ERC1155_init("");
        __Ownable_init(initialOwner);
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        _name = name; // Set the name of the contract or collection
    }

    // Function to set the contract or collection name
    function setName(string memory newName) public onlyOwner {
        _name = newName;
    }

    // Function to get the contract or collection name
    function getName() public view returns (string memory) {
        return _name;
    }

    function mint(address account, uint256 id, uint256 amount, string memory tokenURI) public onlyOwner {
        _mint(account, id, amount, "");
        _setTokenURI(id, tokenURI);
        emit TokenMintedWithURI(account, id, amount, tokenURI);
    }

    // Setter for token URIs
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
    }

    // Getter for token URIs
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId), "ERC1155Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    // Check if token exists
    function exists(uint256 tokenId) public view override returns (bool) {
        return totalSupply(tokenId) > 0;
    }

    // Override required due to Solidity rules
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    // Override the update function to ensure compatibility
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable) {
        super._update(from, to, ids, values);
    }
}
