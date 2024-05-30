// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract PreSale is ReentrancyGuard {
    IERC20 public tokenContract;
    uint256 public rate = 88888;  // Number of tokens per 1 ETH
    
    uint256 public maxTokensForSale; // Hardcoded maximum tokens that can be sold
    uint256 public tokensSold = 0; // Tracking tokens sold

    address public owner;
    bool public preSaleEnded = false;

    mapping(address => uint256) public balances;

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);

    constructor(address tokenAddress) {
        tokenContract = IERC20(tokenAddress);
        owner = msg.sender;
        
        // Set max tokens for sale considering the token's decimals
        uint256 decimals = tokenContract.decimals();
        maxTokensForSale = 350000000024 * (10 ** decimals);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    receive() external payable {
        buyTokens();
    }

    function buyTokens() public payable nonReentrant {
        require(!preSaleEnded, "Pre-sale has ended");
        
        uint256 tokenAmount = msg.value * rate;
        require(tokensSold + tokenAmount <= maxTokensForSale, "Not enough tokens left for sale");

        tokensSold += tokenAmount;
        balances[msg.sender] += tokenAmount;
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function endPreSale() public onlyOwner {
        preSaleEnded = true;
    }

    function claimTokens() public nonReentrant {
        require(preSaleEnded, "Pre-sale is not yet ended");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No tokens to claim");
        balances[msg.sender] = 0;
        require(tokenContract.transfer(msg.sender, amount), "Failed to transfer tokens");
    }

    function withdrawEther() public onlyOwner nonReentrant {
        payable(owner).transfer(address(this).balance);
    }

    function reclaimTokens() public onlyOwner nonReentrant {
        uint256 remainingTokens = tokenContract.balanceOf(address(this));
        require(tokenContract.transfer(owner, remainingTokens), "Failed to reclaim tokens");
    }

    function claimableTokens(address user) public view returns (uint256) {
        return balances[user];
    }

    function isPresaleEnded() public view returns (bool) {
        return preSaleEnded;
    }

    function getTotalTokensLeft() public view returns (uint256) {
        return maxTokensForSale - tokensSold;
    }

    function getTokenBalance() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }
}