// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SwapContractNative is Ownable, ReentrancyGuard {
    mapping(address => uint256) public balances;

    event TokensLocked(address indexed sender, uint256 amount, address indexed recipient);
    event TokensReleased(address indexed recipient, uint256 amount);

    // Constructor to set the initial owner
    constructor(address initialOwner) Ownable(initialOwner) {}

    // Lock native tokens
    function lockTokens(address recipient) public payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than zero");
        balances[recipient] += msg.value;
        emit TokensLocked(msg.sender, msg.value, recipient);
    }

    // Release native tokens
    function releaseTokens(address recipient, uint256 amount) public onlyOwner nonReentrant {
        require(address(this).balance >= amount, "Insufficient contract balance to release");
        (bool sent, ) = recipient.call{value: amount}("");
        require(sent, "Failed to send Ether");
        balances[recipient] -= amount;
        emit TokensReleased(recipient, amount);
    }

    // Function to receive Ether when sent directly to the contract address
    receive() external payable {
        emit TokensLocked(msg.sender, msg.value, msg.sender);
    }
}
