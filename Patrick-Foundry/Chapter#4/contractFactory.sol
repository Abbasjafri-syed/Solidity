// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DataConsumerV3} from "./chainlink.sol";

contract maker { // contract to call another contract using other contract for price feed
    DataConsumerV3 value; // reating return type for contract

    function getChain(address[] calldata indexFeed) external { // adding address in list
        value = new DataConsumerV3(); // deploying contract
         value.dataFeedAddresses(indexFeed); // calling function to add list
       }

    function getIndex(uint indexAdd) external view returns (AggregatorV3Interface) { // getting address at index
         return value.addressIndexlength(indexAdd);    // calling function to get address at index    
       }
}
