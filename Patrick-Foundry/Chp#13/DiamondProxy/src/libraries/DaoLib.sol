// SPDX-License-Identifier: None
pragma solidity ^0.8.2;

library DaoLib {
    bytes32 constant DAO_STORAGE_SLOT = bytes32(abi.encode(uint256(keccak256("diamond.standard.DaoLib.storage")) - 1));

    struct DaoStates {
        uint256 proposalCreatedAt;
        uint256 proposalNum;
        uint256 votingStarts;
        uint256 votingEnds;
        uint256 VoteFavor;
        uint256 VoteAgainst;
        bool proposal_In_Progress;
        bool proposalPassed;
        address DaoOwner;
        mapping(uint256 => bool) proposalExists;
        mapping(address => bool) voteExisted;
    }

    function DaoStorage() internal pure returns (DaoStates storage ds) {
        bytes32 position = DAO_STORAGE_SLOT;

        assembly {
            // storing states at slot
            ds.slot := position
        }
    }
}
