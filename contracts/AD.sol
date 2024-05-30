// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract AirdropFlareBear {
    address public admin;
    IERC20 public token;
    uint256 public tokenAmount;

    constructor(address _tokenAddress) {
        admin = msg.sender;
        token = IERC20(_tokenAddress);
        tokenAmount = 397177 ether;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
        
    }

    function setTokenAmount(uint256 _newTokenAmount) external onlyAdmin {
        tokenAmount = _newTokenAmount;
    }

    function setTokenAddress(address newTokenAddress) external onlyAdmin {
        token = IERC20(newTokenAddress);
    }

    function batchAirdrop(address[] calldata recipients, uint batchSize) external onlyAdmin {
        require(batchSize > 0, "Batch size must be positive");
        require(batchSize <= recipients.length, "Batch size exceeds number of recipients");

        uint256 totalRequiredTokens = tokenAmount * batchSize;
        require(token.balanceOf(address(this)) >= totalRequiredTokens, "Insufficient tokens in contract for batch");

        for (uint i = 0; i < batchSize; i++) {
            if (!token.transfer(recipients[i], tokenAmount)) {
                revert("Token transfer failed");
            }
        }
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyAdmin {
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Token transfer failed");
    }

    function withdrawEther(address payable to, uint256 amount) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }

    receive() external payable { }
}