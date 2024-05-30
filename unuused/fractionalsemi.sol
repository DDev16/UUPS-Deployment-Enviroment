// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract FractionalSemi is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    IERC20 public semiToken;
    
    struct NFTInfo {
        uint256 price;
        uint256 maxSupply;
        uint256 currentSupply;
    }
    
    mapping(uint256 => NFTInfo) public nftDetails;
    mapping(uint256 => uint256) private _totalShares;   
    mapping(uint256 => string) private _tokenURIs;
    
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _semiToken) initializer public {
        __ERC1155_init("https://bafybeid4ozi2ym56jr3tor6eepetzl6nltmdxutoqectqskgd3bx6m2csu.ipfs.nftstorage.link/");
        __Ownable_init(initialOwner);
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init(); 

          semiToken = IERC20(_semiToken);

        // Initialize NFT details
        nftDetails[1] = NFTInfo(3000, 2000, 0); // Night Rider
        nftDetails[2] = NFTInfo(3000, 2000, 0); // Blue Beacon
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

     function setPrice(uint256 id, uint256 price) public onlyOwner {
        nftDetails[id].price = price;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

     /**
     * @dev Returns the price of the NFT specified by its ID.
     * @param id The ID of the NFT.
     * @return price The price of the specified NFT.
     */
    function getPrice(uint256 id) public view returns (uint256 price) {
        require(nftDetails[id].maxSupply != 0, "NFT does not exist.");
        return nftDetails[id].price;
    }

     function mint(address account, uint256 id, uint256 amount, bytes memory data) public nonReentrant {
        require(nftDetails[id].currentSupply + amount <= nftDetails[id].maxSupply, "Exceeds maximum supply");
        require(semiToken.transferFrom(msg.sender, address(this), nftDetails[id].price * amount), "SEMI transfer failed");

        nftDetails[id].currentSupply += amount;
        _mint(account, id, amount, data);
    }


    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public nonReentrant {
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            require(nftDetails[id].currentSupply + amount <= nftDetails[id].maxSupply, "Exceeds maximum supply");
            require(semiToken.transferFrom(msg.sender, address(this), nftDetails[id].price * amount), "SEMI transfer failed");

            nftDetails[id].currentSupply += amount;
        }
        _mintBatch(account, ids, amounts, data);
    }
    
      function addNewTruckModel(uint256 id, uint256 price, uint256 maxSupply) public onlyOwner {
    require(nftDetails[id].maxSupply == 0, "Model already exists");
    nftDetails[id] = NFTInfo(price, maxSupply, 0);
}

    
    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
    require(bytes(_tokenURIs[tokenId]).length == 0, "URI already set");
    _tokenURIs[tokenId] = tokenURI;
    emit URI(tokenURI, tokenId);
    
    }

    function uri(uint256 tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(super.uri(tokenId), "/", Strings.toString(tokenId), ".json"));
    }

        //  function to get NFT details
    function getNFTDetails(uint256 nftId) public view returns (NFTInfo memory) {
        return nftDetails[nftId];
    }


    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }

    /**
     * @dev Returns the version of the contract for testing upgrade success.
     */
    function getContractVersion() public pure returns (string memory) {
        return "v4.0";
    }

    
}
