// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// QuadraticVotingDAO.sol

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";

contract QuadraticVotingDAO is Ownable {
    struct Proposal {
        uint256 id;
        string description;
        uint256 votes;
        uint256 deadline;
        bool executed;
        address payable recipient;
        uint256 amount;
    }

    GovernanceToken public governanceToken;
    Treasury public treasury;
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    uint256 public constant DEFAULT_DURATION = 7 days;

    event ProposalCreated(uint256 id, string description, uint256 deadline, address recipient, uint256 amount);
    event ProposalExecuted(uint256 id);

    constructor(address initialOwner, address _governanceToken, address payable _treasury) Ownable(initialOwner) {
        governanceToken = GovernanceToken(_governanceToken);
        treasury = Treasury(_treasury);
    }

    function createProposal(string memory _description, address payable _recipient, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount <= treasury.getBalance(), "Insufficient treasury funds");

        proposalCount++;
        proposals[proposalCount] =
            Proposal(proposalCount, _description, 0, block.timestamp + DEFAULT_DURATION, false, _recipient, _amount);

        emit ProposalCreated(proposalCount, _description, block.timestamp + DEFAULT_DURATION, _recipient, _amount);
    }

    function vote(uint256 _proposalId, uint256 _tokenAmount) external {
        require(governanceToken.balanceOf(msg.sender) >= _tokenAmount, "Not enough tokens");

        uint256 quadraticVotes = _tokenAmount * _tokenAmount;
        proposals[_proposalId].votes += quadraticVotes;

        governanceToken.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.votes > 0, "No votes received");
        require(block.timestamp >= proposal.deadline, "Voting still in progress");

        proposal.executed = true;
        treasury.withdraw(proposal.recipient, proposal.amount);

        emit ProposalExecuted(_proposalId);
    }
}
