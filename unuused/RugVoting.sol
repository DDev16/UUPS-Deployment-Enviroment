// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Votes {
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);
}

contract VotingSystem {
    struct Proposal {
        uint256 id;
        string description;
        uint256 endTime;
        bool executed;
        mapping(address => uint256) votes;
        uint256 totalVotes;
    }

    Proposal[] public proposals;
    IERC20Votes public token;

    event ProposalCreated(uint256 id, string description, uint256 endTime);
    event Voted(uint256 id, address voter, uint256 votes);
    event ProposalExecuted(uint256 id);

    constructor(address tokenAddress) {
        token = IERC20Votes(tokenAddress);
    }

    function createProposal(string memory description, uint256 votingDuration) public {
        uint256 id = proposals.length;
        Proposal storage newProposal = proposals.push();
        newProposal.id = id;
        newProposal.description = description;
        newProposal.endTime = block.timestamp + votingDuration;
        newProposal.executed = false;

        emit ProposalCreated(id, description, newProposal.endTime);
    }

    function vote(uint256 proposalId, uint256 votes) public {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.endTime, "Voting has ended");
        require(votes <= token.getVotes(msg.sender, block.number - 1), "Not enough votes");

        proposal.votes[msg.sender] += votes;
        proposal.totalVotes += votes;

        emit Voted(proposalId, msg.sender, votes);
    }
    
    function executeProposal(uint256 proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.endTime, "Voting has not ended yet");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        // Add execution logic here based on proposal results.

        emit ProposalExecuted(proposalId);
    }
}