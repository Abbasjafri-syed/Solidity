// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {fundRecv} from "../src/pricing.sol";
import {HelperFeed} from "../script/helperTest.s.sol";

contract deployment is Script {

    // method to deploy contract using script
    // forge script contractName or  forge script script/fileName.s.sol

    function run() public returns (fundRecv) {
        // anything before vm.startBroadcast() is simulated txn

        // deploying HelperFeed contract
        HelperFeed helperFeed = new HelperFeed();

        // saving the address of the contract
        address ETHUSDfeed = helperFeed.networkConfigActive();

        // start is real txn
        vm.startBroadcast();

        //deploying the contract and passing param
        fundRecv funded = new fundRecv(ETHUSDfeed);
        vm.stopBroadcast();

        // returning the address
        return funded;
    }
}
