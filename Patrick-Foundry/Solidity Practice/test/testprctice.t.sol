// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {deployemntScript} from "../script/deploy.s.sol";
import {fundContrct} from "../src/practiceCourse.sol";

contract prcTest is Test {
    fundContrct funded; // declaring data type for contract with variable

    address private caller = makeAddr("caller"); //creating a random address
    
    
    deployemntScript deploy = new deployemntScript(); // deploying deployemntScript contract and saving in variable

    function setUp() external {
        // function must for every test contract
        funded = deploy.run(); // deploying contract and caching it
    }

    function test_contrctBalance() external {
        uint256 balance = funded.contractBalance(); // check contract balance

        console2.log("This is address Balance:", balance);

        assertEq(balance, 0, "this is false"); // validating
    }

    function test_Feed() external view {
        uint256 priceFeed = funded.getTokenPrice(); // chainlink price feed
        console2.log("This is feed price Balance:", priceFeed);
    }

    function test_owner() external {
        console2.log(funded.ownerContract()); //
        assertEq(funded.ownerContract(), address(deploy)); // validate contract owner
    }

    function test_priceFund() external {
        assertEq(funded.contractBalance(), 0);

        hoax(caller, 4 ether); // starting txn and funding caller
        funded.fundContractRefund{value: 0.5 ether}(); // funding contract
        console2.log(funded.contractBalance()); // contract balance 

        // assertEq(funded.contractBalance(), 5912638612169594); // checking contract balance
    }

    // forge test -f $test_rpc_url --mt test_priceFund -vvv

    function test_FundersIndex() external {
        address[] memory makers = new address[](3); //creating an array to add addresses
        makers[0] = caller;
        makers[1] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
        makers[2] = 0xc59E3633BAAC79493d908e63626716e204A45EdF;

        funded.addressMultipleHardcode(makers); // passing addresses into function
        assertEq(funded.getFundersByIndex(0), caller, "First address should be correct"); // checking address at index

        address[] memory fuser = (funded.getFunders()); // caching fuction to get specific address at array

        console2.log(fuser[1]);

        assertEq(fuser[1], 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43); // checking address at given index
    }

    function test_funderBalance() external {
        hoax(caller, 9 ether); // funding caller
        funded.fundContractRefund{value: 2 ether}(); // funding contract
        assertEq(funded.userBalance(caller), 2 ether); // validating balance of user
    }

    function test_funderExist() external {
        assertEq(funded.userExist(caller), false); // validating balance of user

        hoax(caller, 9 ether); // funding caller
        vm.expectRevert(); // cheat code for revert call
        funded.fundContractRefund{value: 1 ether}(); // funding contract with less balance
        vm.stopPrank(); // stoping txn

        hoax(caller, 9 ether); // starting a new call
        funded.fundContractRefund{value: 14 ether}(); // funding with required balance
        assertEq(funded.userExist(caller), true); // validating balance of user
    }

    function test_depositFunderExist() external {
        assertEq(funded.userExist(caller), false); // validating balance of user

        hoax(caller, 9e18); // funding caller
        funded.fundContractRefund{value: 2 ether}(); // funding contract
        assertEq(funded.userExist(caller), true); // validating users exist
        vm.stopPrank(); // stoping txn

        hoax(caller, 9 ether); // starting a new call
        vm.expectRevert(); // expecting call to revert as user exist
        funded.fundContractRefund{value: 2 ether}(); // funding again required balance
        assertEq(funded.userExist(caller), true); // validating balance of user
    }

    function test_timeLimitFund() external {
        console2.log(block.timestamp); //getting current timestamp
        hoax(caller, 9e18); // fudning caller with 9 ether
        funded.fundWithTimelimit{value: 2e18}(); // funding contract with 2 ether
        vm.stopPrank(); // stopping the txn

        console2.log(block.timestamp + 11); // getting time difference
        vm.warp(block.timestamp + 11); // creating time difference
        funded.fundWithTimelimit{value: 2e18}(); // funding contract with 2 ether
        assertEq(funded.contractBalance(), 4e18); // validating contract balance
    }

    function test_Withdraw() external {
        hoax(caller, 9e18); // fudning caller with 9 ether
        funded.fundWithTimelimit{value: 2e18}(); // funding contract with 2 ether

        vm.prank(address(deploy)); // starting call with deployer of contract
        // vm.prank(address(funded));
        funded.withDraw(); // calling withdraw function
        assertEq(funded.contractBalance(), 0); // checking contract balance
        assertEq(address(deploy).balance, 2 ether); // checkingo deployer balance
    }

    // forge test --mt test_Fund -vvv
    // forge test -f $test_rpc_url -vvv --mt test_funderBalance
}
