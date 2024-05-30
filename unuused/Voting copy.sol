// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VotingSystem is Ownable {
    using Counters for Counters.Counter;
    
    struct Proposal {
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        bool canceled;
        uint256 quorum;  // Dynamic quorum for each proposal
        mapping(address => bool) voted;
    }
    
    Counters.Counter private _proposalIdCounter;
    mapping(uint256 => Proposal) public proposals;
    IERC20 public token;

    event ProposalCreated(uint256 proposalId, string description, uint256 startTime, uint256 endTime, uint256 quorum);
    event Voted(uint256 proposalId, address voter, bool vote, uint256 weight);
    event ProposalExecuted(uint256 proposalId, bool result);
    event ProposalCanceled(uint256 proposalId);

    constructor(address tokenAddress) Ownable(msg.sender) {
        token = IERC20(tokenAddress);
    }

    function createProposal(string calldata description, uint256 duration, uint256 proposalQuorum) external onlyOwner {
        require(duration >= 1 days, "Duration must be at least one day");
        require(proposalQuorum > 0, "Quorum must be greater than zero");

        uint256 proposalId = _proposalIdCounter.current();
        Proposal storage newProposal = proposals[proposalId];
        newProposal.description = description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + duration;
        newProposal.quorum = proposalQuorum;
        _proposalIdCounter.increment();
        
        emit ProposalCreated(proposalId, description, newProposal.startTime, newProposal.endTime, proposalQuorum);
    }

     // View function to get proposal details
    function getProposal(uint256 proposalId) public view returns (string memory description, uint256 startTime, uint256 endTime, uint256 yesVotes, uint256 noVotes, bool executed, bool canceled, uint256 quorum) {
        Proposal storage proposal = proposals[proposalId];
        return (proposal.description, proposal.startTime, proposal.endTime, proposal.yesVotes, proposal.noVotes, proposal.executed, proposal.canceled, proposal.quorum);
    }

    // View function to check if an address has voted on a proposal
    function hasVoted(uint256 proposalId, address voter) public view returns (bool) {
        return proposals[proposalId].voted[voter];
    }

    // View function to get the voting results for a proposal
    function getVotingResults(uint256 proposalId) public view returns (uint256 yesVotes, uint256 noVotes) {
        Proposal storage proposal = proposals[proposalId];
        return (proposal.yesVotes, proposal.noVotes);
    }

    function vote(uint256 proposalId, bool votes) external {
        require(proposalId < _proposalIdCounter.current(), "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting not active");
        require(!proposal.voted[msg.sender], "Already voted");
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.canceled, "Proposal was canceled");

        uint256 voterBalance = token.balanceOf(msg.sender);
        require(voterBalance > 0, "Insufficient tokens to vote");

        proposal.voted[msg.sender] = true;

        if (votes) {
            proposal.yesVotes += voterBalance;
        } else {
            proposal.noVotes += voterBalance;
        }

        emit Voted(proposalId, msg.sender, votes, voterBalance);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < _proposalIdCounter.current(), "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp > proposal.endTime, "Voting period has not ended");
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.canceled, "Proposal was canceled");
        require(proposal.yesVotes + proposal.noVotes >= proposal.quorum, "Minimum quorum not reached");

        proposal.executed = true;
        bool result = proposal.yesVotes > proposal.noVotes;
        
        emit ProposalExecuted(proposalId, result);
    }

    function cancelProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < _proposalIdCounter.current(), "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        proposal.canceled = true;
        
        emit ProposalCanceled(proposalId);
    }

    function getProposalCount() public view returns (uint256) {
    return _proposalIdCounter.current();
}

}