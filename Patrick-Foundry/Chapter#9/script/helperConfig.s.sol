// SPDX-License-Identifier: none
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {rafflePractice} from "../src/raffle.sol";

import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract helperConfig is Script {
    struct network_Config {
        address chainlink_Feed;
        uint256 price;
        address coordinator_vrf;
        bytes32 hash;
        uint32 call_Limit;
        uint16 confirmations;
        uint32 num_Values;
        uint64 subscriptionId;
    }

    network_Config public active_Config;

    constructor() {
        block.chainid == 11155111 ? active_Config = sepoliaNetwork() : active_Config = anvilNetwork();
    }

    function sepoliaNetwork() public pure returns (network_Config memory) {
        return network_Config(
            0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            1e18,
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            100000,
            3,
            2,
            0
        );
    }

    function anvilNetwork() public returns (network_Config memory) {
        if (active_Config.coordinator_vrf != address(0)) {
            return active_Config;
        }

        // params for mock cordinator
        uint96 basefee = 0.25 ether;
        uint96 gasPriceLink = 1e9; // 1 gwei

        // vm.startBroadcast();
        MockV3Aggregator mockV3 = new MockV3Aggregator(8, 390012345678);
        VRFCoordinatorV2Mock mock2vrf = new VRFCoordinatorV2Mock(basefee, gasPriceLink);
        // vm.stopBroadcast();

        return network_Config({
            chainlink_Feed: address(mockV3),
            price: 1e18,
            coordinator_vrf: address(mock2vrf),
            hash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            call_Limit: 400000,
            confirmations: 3,
            num_Values: 2,
            subscriptionId: 0
        });
    }
}
