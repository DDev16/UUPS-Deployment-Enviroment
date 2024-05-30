// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
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

    function airdrop(address[] calldata recipients) external onlyAdmin {
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transfer(recipients[i], tokenAmount);
        }
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyAdmin {
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function withdrawEther(address payable to, uint256 amount) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }

    receive() external payable { }
}
