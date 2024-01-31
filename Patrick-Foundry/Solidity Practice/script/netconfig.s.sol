// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract configtest is Script { // deploying script network based
    address feedAddress; // address to store feed address

    function run() public { // method assigning address based on network
        if (block.chainid == 11155111) {
            feedAddress = SepoliaFeed(); // chainlink feed if network seploia
        } else {
            feedAddress = AnvilFeed(); // mock feed if anvil
        }
    }

    constructor() { // constructor will make it possible to assign else feedAddress remain zero
        run(); // calling run to assigning address
    }

    function addressFeed() public view returns (address) { 
        return feedAddress; // getting feed address
    }

    function SepoliaFeed() public pure returns (address) { // method to set feed address
        address Sep = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // chainlink feed for sepolia
        return Sep;
    }

    function AnvilFeed() public returns (address) {
        if (feedAddress != address(0)) { // checking if address already assign
            return feedAddress; // return the feed address
        }
        MockV3Aggregator mockv3 = new MockV3Aggregator(8, 235012345678); // deploying new mock feed
        return address(mockv3); // returning address
    }

    function priceConvert() public payable returns (uint256) {
        uint256 converse = (msg.value * getTokenPrice()) / 1e18; // converting eth into usd
        return converse; // retun value in usd
    }

    function getTokenPrice() public view returns (uint256) { // method to get eth/usd price
        // method to get oracle price
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(feedAddress).latestRoundData(); // calling address to get amount in usd
        return uint256(price) * 1e10; // making  value compatible with 18 decimals
    }
}
