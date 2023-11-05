// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTV1 is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

      struct TokenWithBaseURI {
    uint256 tokenId;
    string baseURI;
}

    string baseURI;
    string public baseExtension = ".json";
    uint256 public presaleCost = 5 ether;
    uint256 public regularCost = 10 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 20;
    bool public paused = false;
    bool public revealed = false;
    string public notRevealedUri;
    bool public presaleActive = true;

    uint256 public nftholderRewardPercentage = 10; // Percentage for NFTholders

    // Mapping to track rewards for NFTholders
    mapping(address => uint256) public nftholderRewards;

    // Owner's share mapping
    mapping(address => uint256) public ownerShares;
    event RevertReason(string reason);

     event Minted(address indexed minter, uint256 amount);
    event Claimed(address indexed claimer, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    // Add this function to your existing contract



    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
   function mint(uint256 _mintAmount) public payable nonReentrant {
        uint256 supply = totalSupply();

        // Check if minting is paused
        if (paused) {
            emit RevertReason("Minting is currently paused");
            return;
        }

        // Check mint amount
        if (_mintAmount == 0) {
            emit RevertReason("Mint amount must be greater than 0");
            return;
        }

        if (_mintAmount > maxMintAmount) {
            emit RevertReason("Mint amount exceeds the maximum allowed");
            return;
        }

        if (supply + _mintAmount > maxSupply) {
            emit RevertReason("Minting would exceed the maximum supply");
            return;
        }

        uint256 cost;

        // Check the pricing mode
        if (presaleActive) {
            cost = presaleCost;
        } else {
            cost = regularCost;
        }

        // Exempt the owner from paying any cost
        if (msg.sender != owner()) {
            if (msg.value < cost * _mintAmount) {
                emit RevertReason("Insufficient payment for minting");
                return;
            }

            // Calculate the NFTholder reward based on the specified percentage
            uint256 nftholderReward = (cost * nftholderRewardPercentage * _mintAmount) / 100;
            nftholderRewards[msg.sender] += nftholderReward;

            // Update owner's share
            ownerShares[owner()] += msg.value - nftholderReward;
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }

        emit Minted(msg.sender, _mintAmount);
    }


    // Function to claim NFTholder rewards
    function claimRewards() public nonReentrant {
        require(nftholderRewards[msg.sender] > 0, "No rewards to claim");
        uint256 rewards = nftholderRewards[msg.sender];
        nftholderRewards[msg.sender] = 0;
        payable(msg.sender).transfer(rewards);
                emit Claimed(msg.sender, rewards);

    }

    // Function to withdraw the owner's share
    function withdrawOwnerShare() public onlyOwner nonReentrant {
        require(ownerShares[owner()] > 0, "No owner's share to withdraw");
        uint256 share = ownerShares[owner()];
        ownerShares[owner()] = 0;
        payable(owner()).transfer(share);
    }

    // Emergency withdrawal function for leftover funds
    function emergencyWithdraw() public onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        payable(owner()).transfer(contractBalance);
    }

  

function walletOfOwnerWithBaseURI(address _owner)
    public
    view
    returns (TokenWithBaseURI[] memory)
{
    uint256 ownerTokenCount = balanceOf(_owner);
    TokenWithBaseURI[] memory tokensWithBaseURI = new TokenWithBaseURI[](ownerTokenCount);
    
    for (uint256 i = 0; i < ownerTokenCount; i++) {
        uint256 tokenId = tokenOfOwnerByIndex(_owner, i);
        string memory baseURI = tokenURI(tokenId);
        
        tokensWithBaseURI[i] = TokenWithBaseURI(tokenId, baseURI);
    }
    
    return tokensWithBaseURI;
}


    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
                : "";
    }

    // Function to toggle between presale and regular pricing mode
    function togglePricingMode() public onlyOwner {
        presaleActive = !presaleActive;
    }

    // Only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    // Set the NFTholder reward percentage, only callable by the owner
    function setNFTholderRewardPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage >= 0 && _percentage <= 100, "Invalid percentage");
        nftholderRewardPercentage = _percentage;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }

    function setRegularCost(uint256 _newCost) public onlyOwner {
        regularCost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}
