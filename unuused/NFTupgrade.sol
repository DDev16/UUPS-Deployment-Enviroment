// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/IERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/IERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract NFTMintingContract is Initializable, UUPSUpgradeable, OwnableUpgradeable, ERC721EnumerableUpgradeable, ReentrancyGuardUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;
    string public baseExtension;
    uint256 public presaleCost; // Cost during presale
    uint256 public cost; // Regular cost after presale
    uint256 public maxSupply;
    uint256 public maxMintAmount;
    bool public paused;
    bool public revealed;
    string public notRevealedUri;
    uint256 public totalProceeds;
    uint256 public rewardPercentage; // Percentage of proceeds to be distributed to NFT holders
    bool public presaleActive; // Toggle for the presale

    mapping(address => uint256) public nftHolderRewards; // Track rewards for NFT holders
    mapping(address => uint256) public ownerWithdrawBalance; // Balance for the contract owner
    event PresaleStatus(bool isActive);
    event OwnershipCheck(address ownerAddress, address senderAddress);

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        uint256 _initialRewardPercentage
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __Ownable_init();

        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);

        baseExtension = ".json";
        presaleCost = 5 ether; // Set the presale cost
        cost = 10 ether; // Set the regular cost
        maxSupply = 1150;
        maxMintAmount = 100;
        paused = false;
        revealed = true;
        rewardPercentage = _initialRewardPercentage;
        presaleActive = true; // Presale is initially active
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

   function mint(uint256 _mintAmount) public payable nonReentrant {
    uint256 supply = totalSupply();
    require(!paused, "Minting is paused");
    require(_mintAmount > 0, "Mint amount must be greater than 0");
    require(_mintAmount <= maxMintAmount, "Mint amount exceeds the maximum allowed");
    require(supply + _mintAmount <= maxSupply, "Minting would exceed the maximum supply");

    uint256 currentCost = presaleActive ? presaleCost : cost;

    require(msg.value >= currentCost * _mintAmount, "Insufficient payment for minting");

    for (uint256 i = 1; i <= _mintAmount; i++) {
        _safeMint(msg.sender, supply + i);
    }

    // Calculate and update the proceeds
    uint256 proceeds = (msg.value * (100 - rewardPercentage)) / 100;
    totalProceeds += proceeds;

    // Calculate rewards for NFT holders (15% of the proceeds)
    uint256 nftHolderReward = (proceeds * 15) / 100;
    nftHolderRewards[msg.sender] += nftHolderReward;

    // Calculate the owner's share (85% of the proceeds)
    uint256 ownerShare = (proceeds * 85) / 100;
    ownerWithdrawBalance[owner()] += ownerShare;
}




    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    // Toggle presale
    function togglePresale(bool _active) public onlyOwner {
        presaleActive = _active;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    // Only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    // Allow NFT holders to claim their rewards
    function claimReward() public nonReentrant {
        uint256 reward = nftHolderRewards[msg.sender];
        require(reward > 0, "No rewards to claim");
        nftHolderRewards[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Reward transfer failed");
    }

    // New function to airdrop NFTs to multiple addresses
    function airdropNFTs(address[] memory recipients) public onlyOwner {
        require(recipients.length > 0, "No recipients provided");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(totalSupply() < maxSupply, "Maximum supply reached");
            require(!_exists(totalSupply() + 1), "Token already minted");

            _safeMint(recipients[i], totalSupply() + 1);
        }
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
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

    function setRewardPercentage(uint256 _newRewardPercentage) public onlyOwner {
        require(_newRewardPercentage <= 100, "Percentage must be between 0 and 100");
        rewardPercentage = _newRewardPercentage;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    // Withdraw owner's share
   function withdrawOwnerShare() public nonReentrant onlyOwner {
    uint256 ownerBalance = ownerWithdrawBalance[msg.sender];
    require(ownerBalance > 0, "No owner balance to withdraw");

    // Calculate the total contract balance
    uint256 contractBalance = address(this).balance;

    // Calculate the owner's share based on the stored balance
    uint256 ownerShare = (contractBalance * ownerBalance) / totalProceeds;

    // Update owner's balance and total proceeds
    ownerWithdrawBalance[msg.sender] = 0;
    totalProceeds -= ownerBalance;

    (bool success, ) = payable(msg.sender).call{value: ownerShare}("");
    require(success, "Owner share withdrawal failed");
}

}