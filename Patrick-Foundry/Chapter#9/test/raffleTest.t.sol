// SPDX-License-Identifier: none

pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {rafflePractice} from "../src/raffle.sol";
import {deployRaffle} from "../script/deployRaffle.s.sol";
import {helperConfig} from "../script/helperConfig.s.sol";

contract raffleTest is Test {
    rafflePractice raffle; // raffle contract
    helperConfig helper_mode; // helper config contract

    address funder = makeAddr("funder"); // creating a new address
    uint256 init_Value = 10 ether; //same as 10e18 or 10* 10 ** 18

    address chainlink_Feed;
    uint256 price;
    address coordinator_vrf;
    bytes32 hash;
    uint32 call_Limit;
    uint16 confirmations;
    uint32 num_Values;
    uint64 subscriptionId;

    function setUp() public {
        // setting function for test
        vm.startPrank(funder);
        deployRaffle deploy_raffle = new deployRaffle(); // deploying raffle contract through script
        (raffle, helper_mode) = deploy_raffle.run(); // assigning contract saved to their type
        vm.stopPrank();

        (chainlink_Feed, price, coordinator_vrf, hash,,,,) = helper_mode.active_Config(); //caching value
        (,,,, call_Limit, confirmations, num_Values, subscriptionId) = helper_mode.active_Config(); // breaking to avoid stack too deep error
        vm.deal(funder, init_Value); // funding user with amount
    }

    function test_owner() external view {
        console2.log(funder);
        console2.log(raffle.owner());
        console2.log(address(helper_mode));
        console2.log(address(this));
    }

    // forge t --mt test_owner -vvv
}
