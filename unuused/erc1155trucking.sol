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
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract TruckingEmpireFractionalNFTs is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    IERC20 public semiToken;
    
    struct NFTInfo {
        uint256 price;
        uint256 maxSupply;
        uint256 currentSupply;
    }
    
    mapping(uint256 => NFTInfo) public nftDetails;
mapping(uint256 => uint256) private _totalShares;   
mapping(uint256 => string) private _tokenURIs;

   

    function initialize(address initialOwner, address _semiToken) initializer public {
        __ERC1155_init("ipfs://bafybeiglhp5tt4yv5lyzgxlf245m2ubfz5rlzqgn7zonh7kg6tcorrn57a");
        __Ownable_init(initialOwner);
        __ERC1155Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init(); // Initialize the reentrancy guard

        semiToken = IERC20(_semiToken);

        // Initialize NFT details
        nftDetails[1] = NFTInfo(3000, 2000, 0); // Night Rider
        nftDetails[2] = NFTInfo(3000, 2000, 0); // Blue Beacon
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public nonReentrant {
        require(nftDetails[id].currentSupply + amount <= nftDetails[id].maxSupply, "Exceeds maximum supply");
        require(semiToken.transferFrom(msg.sender, address(this), nftDetails[id].price * amount), "SEMI transfer failed");

        nftDetails[id].currentSupply += amount;
        _mint(account, id, amount, data);
    }

    function setPrice(uint256 id, uint256 price) public onlyOwner {
        nftDetails[id].price = price;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
    require(bytes(_tokenURIs[tokenId]).length == 0, "URI already set");
    _tokenURIs[tokenId] = tokenURI;
    emit URI(tokenURI, tokenId);
}

        function uri(uint256 tokenId) override public view returns (string memory) {
            return string(abi.encodePacked(super.uri(tokenId), "/", Strings.toString(tokenId), ".json"));
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

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    // Overrides required by Solidity for the ERC1155 and upgradeable contracts.
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable) {
        super._update(from, to, ids, values);
    }

     /**
     * @dev Returns the version of the contract for testing upgrade success.
     */
    function getContractVersion() public pure returns (string memory) {
        return "v4.0";
    }


    function addNewTruckModel(uint256 id, uint256 price, uint256 maxSupply) public onlyOwner {
    require(nftDetails[id].maxSupply == 0, "Model already exists");
    nftDetails[id] = NFTInfo(price, maxSupply, 0);
}

}
