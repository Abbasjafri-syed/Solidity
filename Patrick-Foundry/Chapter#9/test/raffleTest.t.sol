// SPDX-License-Identifier: none

pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {rafflePractice} from "../src/raffle.sol";
import {deployRaffle} from "../script/deployRaffle.s.sol";
import {helperConfig} from "../script/helperConfig.s.sol";

contract raffleTest is Test {
    rafflePractice raffle; // raffle contract
    helperConfig helper_mode; // helper config contract

    event raffleCreated(uint256 indexed raffle_Count); // event for every raffle created
    event raffleFunder(address indexed funder_address); // event for every funder entering raffle

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
    } // forge t --mt test_owner -vvv

    function test_raffleCreate() external {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function

        assertEq(uint256(raffle.current_State()), uint256(rafflePractice.raffle_Status.Exists)); // validating enum value
        assertEq(raffle.time_Ended(), 241); // validating end time
    } // forge t --mt test_raffleCreate -vvv

    function test_nonOwner_raffleCreate() external {
        vm.prank(funder); // caling txn with a normal user

        vm.expectRevert(); // expecting revert as function is called by non owner
        raffle.create_Raffle(); // calling function
    } // forge t --mt test_nonOwner_raffleCreate -vvv

    function test_createRaffleEvent() external {
        vm.expectEmit(false, false, false, false); // expect max of 5 args..1st 4 are bool, last one is address
        // vm.expectEmit(address(raffle)); // check contract is the event emitter by passing the address
        emit raffleCreated(raffle.raffleCount()); // emitting event

        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function
    } // forge t --mt test_createRaffleEvent -vvv

    function test_CountRaffle() external Fund_Raffle {
        vm.warp(260);
        raffle.genrt_random();
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.Raffle_Winner(); // calling to end 1st raffle cycle

        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function
        assertEq(raffle.raffleCount(), 2); // raffle count increase 2
    } // forge t --mt test_CountRaffle -vvv

    function test_EventRaffleEnter() external {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function

        vm.expectEmit(true, false, false, false); // all args are false
        emit raffleFunder(funder);
        // emit raffleFunder(raffle.owner()); // this will fail as it expect the owner address to be emitted

        vm.prank(funder); // caling txn with a normal user
        raffle.enterRaffle{value: 1e18}(); // funding raffle
    } // forge t --mt test_EventRaffleEnter -vvv

    function test_recrdLogRaffleEnter() external {

        vm.recordLogs(); // syntax for logging all events 
        
        hoax(raffle.owner(), 2e18); // starting a call with the owner
        raffle.create_Raffle(); // 1st event emitted from function

        vm.prank(funder); // caling txn with a normal user
        raffle.enterRaffle{value: 1e18}(); // 2nd event emitted

        Vm.Log[] memory event_Entries = vm.getRecordedLogs(); // methods to access logs

        bytes32 create_Event = event_Entries[0].topics[1]; // logs are saved as bytes32 types
        bytes32 fund_Event = event_Entries[1].topics[1]; // 1st topics are access as they stored actual values that are emitted
        

        // assertEq(event_Entries.length, 1);
        assertEq(create_Event, bytes32(uint(0)));
        assertEq(fund_Event, bytes32(uint256(uint160(funder))));
    } // forge t --mt test_recrdLogRaffleEnter -vvv

    function test_fundRaffle() external {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function

        vm.prank(funder); // caling txn with a normal user
        raffle.enterRaffle{value: 1e18}(); // sending 1 ether to enter raffle
        assertEq(address(raffle).balance, 1e18); // validating raffle balance
    } // forge t --mt test_fundRaffle -vvv

    modifier Fund_Raffle() {
        hoax(raffle.owner(), 10e18); // hoax is combine of prank and deal
        raffle.create_Raffle(); // calling function

        vm.prank(funder); // caling txn with a normal user
        raffle.enterRaffle{value: 1e18}(); // sending 1 ether to enter raffle
        _;
    } // modifier to be used in multiple test

    function test_enterRaffleWhenNotExist() external {
        vm.prank(funder); // caling txn with a normal user

        vm.expectRevert("Raffle does Not exists"); // msg can be passed but it has to be same with that of defined in contract
        raffle.enterRaffle{value: 1e18}(); // sending 1 ether to enter raffle
    } // forge t --mt test_enterRaffleWhenNotExist -vvv

    function test_enterRaffleWhenTimeEnds() external {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function

        vm.warp(241); // changing time

        vm.prank(funder); // caling txn with a normal user
        vm.expectRevert("raffle has Ended"); // msg can be passed but it has to be same with that of defined in contract
        raffle.enterRaffle{value: 1e18}(); // sending 1 ether to enter raffle
    } // forge t --mt test_enterRaffleWhenTimeEnds -vvv

    function test_enterRaffleWithLowBalance() external {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.create_Raffle(); // calling function

        vm.prank(funder); // caling txn with a normal user
        vm.expectRevert(rafflePractice.less_Amount.selector); // error with its name and .selector is passed for custom error
        raffle.enterRaffle{value: 1e10}(); // sending 1 ether to enter raffle
    } // forge t --mt test_enterRaffleWithLowBalance -vvv

    function test_funderinRaffle() external Fund_Raffle {
        // modifier to have funded the raffle

        assertEq(raffle.Participants(0), funder); // validating funder if pushed in array
        assertEq(raffle.ticket_Count(funder), 1); // validating funder ticket count
        assertEq(raffle.token_amount(funder), 1 ether); // validating funder if pushed in array
    } // forge t --mt test_funderinRaffle -vvv

    function test_raffleWinner() external Fund_Raffle {
        vm.prank(raffle.owner()); // starting a call with the owner
        raffle.enterRaffle{value: 1e18}();

        vm.prank(funder); // caling txn with a normal user
        raffle.enterRaffle{value: 1e18}(); // funding raffle

        vm.startPrank(raffle.owner()); // continous call by owner
        raffle.enterRaffle{value: 1e18}(); // funding
        raffle.enterRaffle{value: 1e18}(); // funding
        raffle.enterRaffle{value: 1e18}(); // funding
        raffle.enterRaffle{value: 1e18}(); // funding
        raffle.enterRaffle{value: 1e18}(); // funding mulitple to impact random number generation

        vm.warp(254); // time for ending raffle
        raffle.genrt_random(); // calling random value for selecting raffle

        // raffle.enterRaffle{value: 1e18}(); // again funding

        // console2.log('this is last Value : ',raffle.last_randomValue());
        console2.log("this is latest Value : ", raffle.latest_randomValue());
        // console2.log("this is funder array:", raffle.Participants(0));
        console2.log("This is Funders Length:", raffle.funders_Length());

        raffle.Raffle_Winner();
        // console2.log("This is winner: ", raffle.winner_Update());
        // console2.log("This is funder: ", funder);
    } // forge t --mt test_raffleWinner -vvv

    function test_varRaffleEnd() external Fund_Raffle {
        vm.warp(254); // time for ending raffle
        raffle.genrt_random(); // calling random value for selecting raffle
        assertEq(raffle.last_randomValue(), 0); // last random value is 0 here

        // assert(raffle.last_randomValue() != raffle.latest_randomValue()); // validating values are not same
        assertNotEq(raffle.last_randomValue(), raffle.latest_randomValue()); // same as above

        vm.startPrank(raffle.owner()); // continous call by owner
        raffle.Raffle_Winner(); // caling function

        assertEq(raffle.funders_Length(), 0); // funder array is reset
        assertEq(uint256(raffle.current_State()), uint256(rafflePractice.raffle_Status.not_Exists)); //converting enum to match funder length
        assertEq(raffle.last_randomValue(), raffle.latest_randomValue()); // validating last value == latest value
    } // forge t --mt test_varRaffleEnd -vvv

    function test_upkeepCheck() external {
        vm.prank(raffle.owner()); // owner call
        raffle.create_Raffle(); // calling function

        (bool success,) = raffle.check_UpKeep("0x00"); // calling upkeep when time not up
        assertEq(success, false);

        vm.prank(funder);
        raffle.enterRaffle{value: 1e15}(); // funding raffle

        vm.warp(242); //  end time limit
        (success,) = raffle.check_UpKeep("0x00"); // calling upkeep after all requirement met
        assertEq(success, true);
    } // forge t --mt test_upkeepCheck -vvv

    function test_randomGenerate() external Fund_Raffle {
        vm.expectRevert( // only 3 args are allowed
            abi.encodeWithSelector(
                rafflePractice.upKeep_notRequired.selector,
                address(raffle).balance,
                raffle.funders_Length(),
                raffle.current_State()
            )
        );
        raffle.genrt_random();
    } // forge t --mt test_randomGenerate -vvv

    function test_ran_TimeCondition() external Fund_Raffle {
        vm.expectRevert(); // expecting revert as time not passed
        raffle.genrt_random();

        vm.warp(242); // time passing raffle end
        raffle.genrt_random();
    } // forge t --mt test_ran_TimeCondition -vvv

    function test_ran_Chain() external Fund_Raffle {
        vm.expectRevert();
        raffle.getRandom();
    } // forge t --mt test_ran_Chain -vvv

    function test_raffleReset() external {
        vm.startPrank(raffle.owner()); // starting call with owner
        raffle.create_Raffle(); // creating raffle

        vm.expectRevert("Raffle does not end"); // revrt msg should be same as in contract
        raffle.reset_Raffle(); // calling reset mapping function
    } // forge t --mt test_raffleReset -vvv

    function test_ResetRaffle_aftertimeandFunders() external Fund_Raffle {
        vm.warp(250); // time passed raffle

        vm.prank(raffle.owner()); // call with owner
        vm.expectRevert(rafflePractice.participant_presents.selector); // custom error
        raffle.reset_Raffle(); // calling reset mapping function
    } // forge t --mt test_ResetRaffle_aftertimeandFunders -vvv

    function test_AfterTimeRaffleReset() external {
        vm.startPrank(raffle.owner()); // starting call with owner
        raffle.create_Raffle(); // creating raffle

        vm.warp(250); // time passed raffle
        raffle.reset_Raffle(); // calling reset mapping function
        assertEq(uint256(raffle.current_State()), uint256(rafflePractice.raffle_Status.not_Exists)); // validating raffle status
    } // forge t --mt test_AfterTimeRaffleReset -vvv
}
