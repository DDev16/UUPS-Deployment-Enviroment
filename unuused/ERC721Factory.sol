// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract ChibiFactoryNFTs is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    IERC1155 public chibiFactoryTraits;
    uint256 public _nextTokenId;

    // Mapping to store the associated trait IDs for each ERC721 token
    mapping(uint256 => uint256[]) public tokenToTraitIds;

    function initialize(address _chibiFactoryTraitsAddress) public initializer {
        __ERC721_init("ChibiFactoryNFTs", "CFN");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        chibiFactoryTraits = IERC1155(_chibiFactoryTraitsAddress);
        _nextTokenId = 1;
    }

    function mintNFT(uint256[] memory _requiredTraitIds) public {
        require(canMint(msg.sender, _requiredTraitIds), "Not eligible to mint NFT");

        uint256 newTokenId = _nextTokenId++;
        _safeMint(msg.sender, newTokenId);
        tokenToTraitIds[newTokenId] = _requiredTraitIds;
    }

    function updateTraitIds(uint256 _tokenId, uint256[] memory _newTraitIds) public onlyOwner {
    require(ownerOf(_tokenId) == msg.sender, "You do not own the ERC721 token");

    uint256[] storage oldTraitIds = tokenToTraitIds[_tokenId];
    for (uint256 i = 0; i < oldTraitIds.length; i++) {
        // Remove the old traits from the association
        if (!contains(_newTraitIds, oldTraitIds[i])) {
            oldTraitIds[i] = 0;
        }
    }

    

    // Add the new traits to the association and check ownership
    for (uint256 i = 0; i < _newTraitIds.length; i++) {
        if (!contains(oldTraitIds, _newTraitIds[i])) {
            require(chibiFactoryTraits.balanceOf(msg.sender, _newTraitIds[i]) > 0, "You do not own the trait ID");
            oldTraitIds.push(_newTraitIds[i]);
        }
    }
}


function isTraitAvailableForListing(uint256 traitId) public view returns (bool) {
    for (uint256 i = 1; i < _nextTokenId; i++) {
        if (contains(tokenToTraitIds[i], traitId)) {
            return false;
        }
    }
    return true;
}

// Getter function for _nextTokenId
    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    function canMint(address user, uint256[] memory _requiredTraitIds) public view returns (bool) {
        for (uint256 i = 0; i < _requiredTraitIds.length; i++) {
            if (chibiFactoryTraits.balanceOf(user, _requiredTraitIds[i]) == 0) {
                return false;
            }
        }
        return true;
    }

    function contains(uint256[] memory array, uint256 element) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // Add other ERC721 functions as needed
}
