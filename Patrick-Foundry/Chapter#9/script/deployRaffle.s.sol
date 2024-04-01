// SPDX-License-Identifier: none

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {rafflePractice} from "../src/raffle.sol";
import {helperConfig} from "./helperConfig.s.sol";

contract deployRaffle is Script {
    receive() external payable {}

    function run() public returns (rafflePractice, helperConfig) {
        // functionn to deploy raffle contract and configuration
        helperConfig net_Config = new helperConfig();

        (
            address chainlink_Feed,
            uint256 price,
            address coordinator_vrf,
            bytes32 hash,
            uint32 call_Limit,
            uint16 confirmations,
            uint32 num_Values,
            uint64 subscriptionId
        ) = net_Config.active_Config();

        // vm.startBroadcast();
        rafflePractice raffle = new rafflePractice(
            chainlink_Feed, price, coordinator_vrf, hash, call_Limit, confirmations, num_Values, subscriptionId
        );
        // vm.stopBroadcast();

        return (raffle, net_Config);
    }
}
