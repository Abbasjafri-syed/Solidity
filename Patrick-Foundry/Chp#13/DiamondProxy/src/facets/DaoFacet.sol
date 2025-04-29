// SPDX-License-Identifier: None
pragma solidity ^0.8.2;

import {DaoLib} from "../libraries/DaoLib.sol";
import {IDao} from "../interfaces/IDao.sol";
import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract DaoFacet is Initializable, IDao {
    DaoLib.DaoStates private ds;

    modifier onlyOwner() {
        require(msg.sender == ds.DaoOwner, "Not Authorize");
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function DaoInit(address Owner) external initializer {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        das.DaoOwner = Owner;
    }

    function createProposal() external onlyOwner {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        require(!das.proposal_In_Progress, "Another Proposal Already Exists");
        das.proposal_In_Progress = true;
        das.proposalCreatedAt = block.timestamp;
        das.votingStarts = das.proposalCreatedAt + 1 days;
        das.votingEnds = das.votingStarts + 1 weeks;
        das.proposalNum++;
    }

    function checkProposal(uint256 proposalId) external view returns (bool) {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        return das.proposalExists[proposalId];
    }

    function castVoteFavor(uint256 proposalId) external {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        require(block.timestamp >= das.votingStarts, "Voting not Started");
        require(block.timestamp <= das.votingEnds, "Vote time already ended");
        require(das.proposal_In_Progress, "Another proposal already exists");
        require(das.proposalExists[proposalId], "Proposal not exists");
        require(das.voteExisted[msg.sender], "Vote already casted");
        das.voteExisted[msg.sender] = true;
        das.VoteFavor++;
    }

    function castVoteAgainst(uint256 proposalId) external {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        require(block.timestamp >= das.votingStarts, "Voting not Started");
        require(block.timestamp <= das.votingEnds, "Vote time already ended");
        require(das.proposal_In_Progress, "Another proposal already exists");
        require(das.proposalExists[proposalId], "Proposal not exists");
        require(das.voteExisted[msg.sender], "Vote already casted");
        das.voteExisted[msg.sender] = true;
        das.VoteAgainst++;
    }

    function proposalResult(uint256 proposalId) external view returns (string memory) {
        DaoLib.DaoStates storage das = DaoLib.DaoStorage();
        require(block.timestamp > das.votingEnds, "Voting Going On");
        require(das.proposalExists[proposalId], "Proposal not exists");
        if (das.VoteFavor > das.VoteAgainst) {
            return "Proposal Passed";
        } else if (das.VoteAgainst > das.VoteFavor) {
            return "Proposal Rejected";
        } else if (das.VoteAgainst == das.VoteFavor) {
            return "Vote Counts are Equal";
        } else {
            revert();
        }
    }
}
