// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {ERCtoken} from "../src/ErcToken.sol";
import {TokenERCScript} from "../script/ERCDeploy.s.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract ERCTokenTest is Test {
    TokenERCScript ERCdeploy; // deployment script contract
    ERCtoken ERT20; // erc20 token

    address makerOne = makeAddr("funder"); // one method of making address
    address makerTwo = address(0x2); // second one
    address makerThree = address(1); // third one

    function setUp() external {
        ERCdeploy = new TokenERCScript();
        ERT20 = ERCdeploy.run();
    }

    function test_tknName() external view {
        console.log("Token Address:", address(ERT20)); // checking token address
        console.log("Script Address:", address(ERCdeploy)); // checking script contract address
        console.log("Token owner:", ERT20.owner()); // checking token name
        console.log("Test Contract Address:", address(this)); // checking test contract address
        console.log("Token Name:", ERT20.name()); // checking token name
        console.log("Token Symbol:", ERT20.symbol()); // checking token name
        console.log("Token Decimals:", ERT20.decimals()); // checking token decimals
        console.log("Token Current Supply: %e", ERT20.totalSupply()); // checking token supply
        console.log("Token Maximum Supply: %e", ERT20.getMaximumSupply()); // checking Max supply
    } // forge t --mt test_tknName -vv

    function test_accountBalance() external view {
        assertEq(ERT20.balanceOf(address(ERCdeploy)), 210 ether); // checking deployer balance
    } // forge t --mt test_accountBalance -vv

    function test_transferBalance() external {
        // --continue--
        // console.log("User One:", makerOne); // Method for making an address
        // console.log("User Two:", makerTwo);
        // console.log("User Three:", makerThree);
        console.log("Deployer Initial balance: %e", ERT20.balanceOf(address(ERCdeploy))); // sender balance
        vm.prank(address(ERCdeploy)); // starting call with deployer
        ERT20.transfer(makerOne, 10e18); // making transfer
        assertEq(ERT20.balanceOf(makerOne), 10e18); // checking on balance of recipient
    } // forge t --mt test_transferBalance -vv

    function test_boolValueonTransfer() external {
        vm.prank(address(ERCdeploy)); // starting call with deployer
        bool transfer_Check = ERT20.transfer(makerOne, 10e18); // making transfer
        assertEq(transfer_Check, true); // checking on return value
    } // forge t --mt test_boolValueonTransfer -vv

    function test_AllowanceLimit() external view {
        assertEq((ERT20.allowance(address(ERT20), makerOne)), 0); // asserting allowance to spender
    } // forge t --mt test_AllowanceLimit -vv

    function test_NonHolderTokenApproveAllowance() external {
        console.log("Test contract Address:", address(this)); // caller of allowance function
        console.log("Test contract Balance:", ERT20.balanceOf(address(this))); // balance of contract

        ERT20.approve(makerOne, 10e18); // calling approve function with test contract as caller and no balance
        assertNotEq((ERT20.allowance(address(ERT20), makerOne)), 10e18); // asserting  value is not equal to allowance as no approve take place
    } // forge t --mt test_NonOwnerTokenApproveAllowance -vv

    function test_HolderTokenApproveAllowance() external {
        vm.startPrank(address(ERCdeploy));
        ERT20.approve(makerOne, 10e18); // calling approve function with test contract as caller and no balance
        assertEq((ERT20.allowance(address(ERCdeploy), makerOne)), 1e19); // asserting  value is not equal to allowance as no approve take place
    } // forge t --mt test_HolderTokenApproveAllowance -vv

    function test_ApproveLessToken() external {
        console.log("Deployer contract Balance: %e", ERT20.balanceOf(address(ERCdeploy))); // deployer balance
        uint256 deployer_Balance = ERT20.balanceOf(address(ERCdeploy)); // caching deployer balance
        vm.startPrank(address(ERCdeploy));
        vm.expectRevert("Funds are less than approve amount"); // testing custom code added in approve
        ERT20.approve(makerOne, deployer_Balance + 1e18); // calling approve function with test contract as caller and no balance
    } // forge t --mt test_ApproveLessToken -vv

    function test_ApproveZeroToken() external {
        vm.startPrank(address(ERCdeploy)); // starting call with deployer

        vm.expectRevert(ERC20.ZeroValueApproval.selector); // testing custom code added in approve for custom error with param
        // vm.expectRevert(abi.encodeWithSelector(ERC20.ZeroValueApproval.selector, 0)); // testing custom code added in approve for custom error without param
        ERT20.approve(makerOne, 0); // calling approve function with test contract as caller and no balance
    }

    function test_transferfromNoSpender() external {
        vm.startPrank(makerOne); // starting call with user
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector,
                makerOne,
                ERT20.allowance(address(ERCdeploy), makerOne),
                1e19
            )
        ); // call revert as there is no spender
        ERT20.transferFrom(address(ERCdeploy), makerOne, 10e18); // calling function
    } // forge t --mt test_transferfromNoSpender -vv

    function test_transferfromSpenderApprove() external {
        vm.startPrank(address(ERCdeploy)); // starting call with deployer
        ERT20.approve(makerOne, 1e19); // approving token to spender

        vm.startPrank(makerOne); // starting call with user
        ERT20.transferFrom(address(ERCdeploy), makerTwo, 1e18); // calling function
        assertEq(ERT20.balanceOf(makerTwo), 1e18);
    } // forge t --mt test_transferfromSpenderApprove -vv

    function test_spenderTransferApprove() external {
        // transfer function
        vm.prank(address(ERCdeploy)); // starting call with deployer
        ERT20.approve(makerOne, 1e19); // approving token to spender
        console.log("Spender Balance:", makerOne.balance); //printing spender balance

        vm.startPrank(makerOne); // starting call with user
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, makerOne, makerOne.balance, 1e18)
        ); // expecting revert with params
        ERT20.transfer(makerTwo, 1e18); // calling function
    } // forge t --mt test_spenderTransferApprove -vv

    function test_TokenMintonFunding() external {
        console.log("user initial Balance", ERT20.balanceOf(makerOne)); // printing sender balance

        hoax(makerOne, 11 ether); // combine prank and deal
        address(ERT20).call{value: 10 ether}(""); // low level call
        // console.log("User current Balance: %e", ERT20.balanceOf(makerOne)); // printing sender balance
        // console.log("Total Supply: %e", ERT20.totalSupply()); // printing sender balance
        assertEq(ERT20.balanceOf(makerOne), 5e21);
    } // forge t --mt test_TokenMintonFunding -vv

    function test_MakeSendcallToMintToken() external {
        uint256 SenderBalance = ERT20.balanceOf(makerOne); // caching sender balance
        console.log("Initial Balance", SenderBalance); // printing sender balance

        hoax(makerOne, 11 ether); // combine prank and deal
        console.log("Contract Balance initial: %e", (address(ERT20).balance)); // printing contract balance

        address payable token = payable(address(ERT20)); // cachng token address and making payable for using transfer & send method
        vm.expectRevert(); // revert due to insufficient gas
        // token.transfer(10 ether); // sending via transfer method
        (bool success) = token.send(10 ether); // only applicable when receive or fallback has no logic
        require(success == true, "Value is not True"); // bool return on send
    } // forge t --mt test_MakeSendcallToMintToken -vv

    function test_sendPayable() external {
        console.log("Contract current Balance : %e", (address(ERT20).balance)); // printing sender balance

        hoax(makerOne, 11 ether); // combine prank and deal
        ERT20.maker{value: 10e18}(); // sending fund to mint token when maker function is the logic function

        // console.log("Contract current Balance : %e", (address(ERT20).balance)); // printing contract balance
        // console.log("Sender current Balance: %e", ERT20.balanceOf(makerOne)); // printing sender balance
        // console.log("Token Current Supply: %e", ERT20.totalSupply()); // coin current supply
        assertEq(ERT20.balanceOf(makerOne), 5e21); // asserting sender balance after funding contract
    }
    // forge t --mt test_sendPayable -vv

    function test_TokenMintAmountThreshold() external {
        // console.log("Contract current Balance : %e", (address(ERT20).balance)); // printing sender balance
        // console.log("Token start Current Supply for 1: %e", ERT20.totalSupply()); // checking total supply

        hoax(makerOne, 11 ether); // combine prank and deal
        ERT20.maker{value: 2e18}(); // sending fund to mint token when maker function is the logic function
        // console.log("Contract current Balance : %e", (address(ERT20).balance)); // printing contract balance
        // console.log("1st sender current Balance: %e", ERT20.balanceOf(makerOne)); // printing sender balance
        // console.log("Token end Current Supply for 1: %e", ERT20.totalSupply()); // checking total supply
        assertEq(ERT20.balanceOf(makerOne), 1000 ether); // asserting sender balance after funding contract
        assertEq(ERT20.totalSupply(), 1210 ether); //asserting token supply at current level

        hoax(makerTwo, 11 ether); // combine prank and deal
        ERT20.maker{value: 1e18}(); // sending fund to mint token when maker function is the logic function
        // console.log("2nd sender current Balance: %e", ERT20.balanceOf(makerTwo)); // printing sender balance
        // console.log("Token Current Supply end for 2: %e", ERT20.totalSupply()); // checking total supply
        assertEq(ERT20.balanceOf(makerTwo), 250 ether); // asserting sender balance after funding contract
        assertEq(ERT20.totalSupply(), 1460 ether); //asserting token supply at current level
    } // forge t --mt test_TokenMintAmountThreshold -vv

    function test_sendEthToken() external {
        vm.deal(makerTwo, 11 ether); // combine prank and deal
        // console.log("makerTwo Balance ETH: %e", makerTwo.balance); // makerOne  balance

        vm.startPrank(makerTwo);
        address(ERT20).call{value: 10e18}(""); // sending balance to ERT20 contract
        // console.log("ERT20 Balance ETH: %e", address(ERT20).balance); // ERT20 contract balance
        assertEq(address(ERT20).balance, 1e19); // asserting balance transfer as expected
        vm.stopPrank();

        vm.startPrank(address(ERT20));
        makerOne.call{value: address(ERT20).balance}(""); // sending balance to makerOne
        // console.log("makerOne Balance ETH: %e", makerOne.balance);
        // console.log("ERT20 Balance ETH: %e", address(ERT20).balance); // ERT20 contract balance
        assertEq(address(makerOne).balance, 10 ether); // balance of recpnt after low level call
        assertEq(address(ERT20).balance, 0); // balance of contract after transfer
    } // forge t --mt test_sendEthToken -vv

    function test_UpdateSupplyIncrease() external {
        console.log("Token Supply: %e", ERT20.totalSupply()); // token current supply
        hoax(makeAddr("dEaD"), 2e18); // starting call with deployer
        // console.log("Contract Balance: %e", address(this).balance); // balance of caller
        address caller = ERT20.mint_Tokens{value: 1e18}(makerOne); // calling function with passing 1 eth and recpent param
        // console.log("function Caller:", caller);
        assertEq(ERT20.balanceOf(makerOne), 500 ether); // balance of recpent after transfer
        // assertEq(address(address(0)).balance, 1 ether); // ETH balance of sender
        assertEq(ERT20.totalSupply(), 7.1e20); // current supply after minting
        assertEq(caller, makeAddr("dEaD")); // asserting caller of the function
    } // forge t --mt test_UpdateSupplyIncrease -vv

    function test_SupplyLimitTokenMint() external {
        // console.log("Token Supply: %e", ERT20.totalSupply()); // token current supply
        vm.deal(makerOne, 10 ether); // funding user 1
        vm.deal(makerTwo, 10 ether); // funding user 2

        uint256 startTime = block.timestamp; // current time == 1

        vm.warp(startTime + 1 days); // creating time limit for
        vm.prank(makerOne); // pranking from 1st user
        address(ERT20).call{value: 2e18}(""); // sending balance to ERT20 contract
        // console.log("1st Sender current Balance: %e", ERT20.balanceOf(makerOne)); // printing sender balance
        assertEq(ERT20.balanceOf(makerOne), 1000 ether); // vaildating user balance
        assertEq(ERT20.totalSupply(), 1210 ether); // vaildating token Supply

        vm.prank(makerTwo); // pranking from 1st user
        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        address(ERT20).call{value: 1e18}(""); // sending balance to ERT20 contract
    } // forge t --mt test_SupplyLimitTokenMint -vv

    function test_TimeLimitTokenMint() external {
        // console.log("Token Supply: %e", ERT20.totalSupply()); // token current supply
        vm.deal(makerOne, 10 ether); // funding user 1
        vm.deal(makerTwo, 10 ether); // funding user 2

        uint256 startTime = block.timestamp; // current time == 1

        vm.warp(startTime + 1 days); // creating time limit
        vm.prank(makerOne); // pranking from 1st user
        address(ERT20).call{value: 3e18}(""); // sending balance to ERT20 contract
        // console.log("1st Sender current Balance: %e", ERT20.balanceOf(makerOne)); // printing sender balance
        assertEq(ERT20.balanceOf(makerOne), 1500 ether); // vaildating user balance
        assertEq(ERT20.totalSupply(), 1710 ether); // vaildating token Supply

        vm.warp(startTime + 2 days); // creating time limit
        vm.prank(makerTwo); // pranking from 1st user
        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        address(ERT20).call{value: 1e18}(""); // sending balance to ERT20 contract
    } // forge t --mt test_TimeLimitTokenMint -vv

    function test_TotalSupplyLimitTokenMint() external {
        // console.log("Token Supply: %e", ERT20.totalSupply()); // token current supply
        vm.deal(makerOne, 10 ether); // funding user 1
        uint256 startTime = block.timestamp; // current time == 1

        vm.warp(startTime + 2 days); // creating time limit
        vm.prank(makerOne); // pranking from 1st user
        // vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        address(ERT20).call{value: 7.56e18}(""); // sending balance to ERT20 contract
        assertEq(ERT20.totalSupply(), 2100 ether); // vaildating token Supply
            // console.log("Token Total Supply: %e", ERT20.totalSupply()); // printing total supply
    } // forge t --mt test_TotalSupplyLimitTokenMint -vv

    function test_LimitExceedinTime() external {
        vm.deal(makerOne, 20 ether); // funding user 1
        vm.deal(makerTwo, 10 ether); // funding user 2

        uint256 startTime = block.timestamp + 1 days;

        vm.warp(startTime); // creating time limit for 1st stage
        vm.startPrank(makerOne); // pranking from 1st user
        (bool success,) = address(ERT20).call{value: 2e18}(""); // sending balance at first stage
        require(success == true, "Balance not send"); // check return value of low level
        // console.log("Token Total Supply at 1st stage: %e", ERT20.totalSupply()); // printing total supply
        assertEq(ERT20.totalSupply(), 1210 ether); // vaildating token Supply

        // expected revert calls when 1st stage limit is up
        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        ERT20.mint_Tokens{value: 1e18}(makerTwo); // sending balance to 2nd user

        vm.warp(startTime + 1 days); // creating time limit for 2nd Stage
        // vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply())); // expected revert calls
        ERT20.mint_Tokens{value: 1.2e18}(makerTwo); // sending balance to 2nd user
        // console.log("Token Total Supply: %e", ERT20.totalSupply()); // printing total supply
        assertEq(ERT20.totalSupply(), 1510 ether); // vaildating token Supply

        // expected revert calls when 2nd stage limit is up
        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        (success,) = address(ERT20).call{value: 1e18}(""); // sending balance to ERT20 contract
        // console.log("Boolean", success); // checking bool value
        require(success == true, "Balance not send"); // check return value of low level
        console.log("Token Total Supply: %e", ERT20.totalSupply()); // printing total supply

        vm.warp(startTime + 2 days); // creating time limit for 3rd Stage
        ERT20.mint_Tokens{value: 5.9e18}(makerTwo); // sending balance to 2nd user
        // assertEq(ERT20.totalSupply(), 2100 ether); // vaildating token Supply
        console.log("Token Total Supply: %e", ERT20.totalSupply()); // printing total supply

        // expected revert calls when 2nd stage limit is up
        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.totalSupply()));
        (success,) = address(ERT20).call{value: 1e18}(""); // sending balance to ERT20 contract
        // console.log("Boolean", success); // checking bool value
        require(success == true, "Balance not send"); // check return value of low level
            // console.log("Token Total Supply: %e", ERT20.totalSupply()); // printing total supply
    } // forge t --mt test_LimitExceedinTime -vv

    // test burn , test emit event

    function test_BurnTokens() external {
        vm.deal(makerOne, 15 ether); // funding user 1
        // console.log("Token Current Minted Before Burning: %e", ERT20.CurrentMintedAmount()); // printing total supply
        uint256 startTime = block.timestamp + 1 days;

        vm.warp(startTime); // creating time limit for 1st stage
        vm.startPrank(makerOne); // starting call with user 1
        (bool success,) = address(ERT20).call{value: 2e18}(""); // sending balance at first stage
        require(success == true, "Balance not send"); // check return value of low level
        // console.log("Token Total Supply at 1st stage: %e", ERT20.totalSupply()); // printing total supply
        assertEq(ERT20.totalSupply(), 1210 ether); // vaildating token Supply

        ERT20.burn_token(10 ether);
        // console.log("Token Total Supply after Burning stage: %e", ERT20.totalSupply()); // printing total supply
        // console.log("Token Current Minted Amount after Burning: %e", ERT20.CurrentMintedAmount()); // printing total supply
        assertEq(ERT20.totalSupply(), 1200 ether); // vaildating token Supply
        assertEq(ERT20.CurrentMintedAmount(), 1210); // vaildating token Supply

        vm.warp(startTime + 1 days); // creating time limit for 2nd Stage
        (success,) = address(ERT20).call{value: 2e18}(""); // sending balance at first stage
        require(success == true, "Balance not send"); // check return value of low level
        // console.log("Token Total Supply at 2nd stage: %e", ERT20.totalSupply()); // printing total supply
        assertEq(ERT20.totalSupply(), 1700 ether); // vaildating token Supply
        assertEq(ERT20.CurrentMintedAmount(), 1710); // vaildating token Supply

        ERT20.burn_token(100 ether);
        assertEq(ERT20.totalSupply(), 1600 ether); // vaildating token Supply
        assertEq(ERT20.CurrentMintedAmount(), 1710); // vaildating token Supply

        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.CurrentMintedAmount() * 1 ether));
        (success,) = address(ERT20).call{value: 2e18}(""); // sending balance at first stage
        require(success == true, "Balance not send at 2nd Stage"); // check return value of low level

        vm.warp(startTime + 2 days); // creating time limit for 3rd Stage
        ERT20.mint_Tokens{value: 3e18}(makerTwo); // sending balance to 2nd user
        // console.log("Token Total Minted: %e", ERT20.CurrentMintedAmount()); // printing total supply
        // console.log("Token Total Supply at 3rd stage: %e", ERT20.totalSupply()); // printing total supply
        assertEq(ERT20.CurrentMintedAmount(), 2010); // vaildating token Supply
        assertEq(ERT20.totalSupply(), 1900 ether); // vaildating token Supply

        // vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.CurrentMintedAmount() * 1 ether)); // expecting revert with custom error
        vm.expectRevert("Minting cannot exceed MaxSupply");
        ERT20.mint_Tokens{value: 1e18}(makerTwo); // sending balance to 2nd user

        ERT20.mint_Tokens{value: 9e17}(makerTwo); // sending balance to 2nd user
        assertEq(ERT20.CurrentMintedAmount(), 2100); // vaildating token Supply
        assertEq(ERT20.totalSupply(), 1990 ether); // vaildating token Supply

        vm.expectRevert(abi.encodeWithSelector(ERCtoken.Over_Supply.selector, ERT20.CurrentMintedAmount() * 1 ether)); // expecting revert with custom error
        ERT20.mint_Tokens{value: 1e18}(makerTwo); // sending balance to 2nd user
    } // forge t --mt test_BurnTokens -vv

    event Transfer(address indexed sender, address indexed recipient, uint256 value); // defining event to be emitted

    function test_EventonTransfer() external {
        hoax(makerOne, 20 ether); // funding user 1

        uint256 startTime = block.timestamp + 1 days;
        vm.warp(startTime); // creating time limit for 1st stage

        vm.expectEmit(true, true, false, false, address(ERT20)); // 1st argument must be true to pass test or pass empty parentheses
        // vm.expectEmit(address(ERT20)); // passing only address is the checking on emitter
        emit Transfer(address(0), makerOne, 1000 ether);

        address(ERT20).call{value: 2e18}(""); // sending balance at first stage
            // ERT20.mint_Tokens{value: 2e18}(makerTwo); // sending balance to 2nd user
    } // forge t --mt test_EventonTransfer -vv

    function test_LogsEventTransfer() external {
        hoax(makerOne, 20 ether); // funding user 1
        uint256 startTime = block.timestamp + 1 days;
        vm.recordLogs(); // method to record events

        vm.warp(startTime); // creating time limit for 1st stage
        address(ERT20).call{value: 1e18}(""); // sending balance at first stage

        vm.warp(startTime + 1 days); //  // creating time limit for 2nd stage
        ERT20.mint_Tokens{value: 1e18}(makerTwo); // sending balance to 2nd user

        vm.warp(startTime + 2 days); // creating time limit for 1st stage
        address(ERT20).call{value: 1e18}(""); // sending balance at first stage

        Vm.Log[] memory Events_Stage = vm.getRecordedLogs(); // method to get all stored events emitted till now

        bytes32 stage_01_Sender = Events_Stage[0].topics[1]; // event emitted 1st param
        bytes32 stage_01_Recipient = Events_Stage[0].topics[2]; // event emitted 2nd param
        console.log("Events Length", Events_Stage.length);

        assertEq(stage_01_Sender, bytes32(uint256(uint160(address(0))))); // asserting mint from address(0)
        assertEq(stage_01_Recipient, bytes32(uint256(uint160(makerOne)))); // asserting 1st event recipient

        bytes32 stage_02_Sender = Events_Stage[1].topics[1]; // event emitted 1st param
        bytes32 stage_02_Recipient = Events_Stage[1].topics[2]; // event emitted 2nd param

        assertEq(stage_02_Sender, bytes32(uint256(uint160(address(0))))); // asserting mint from address(0)
        assertEq(stage_02_Recipient, bytes32(uint256(uint160(makerTwo)))); // asserting 2nd event recipient

         bytes32 stage_03_Sender = Events_Stage[2].topics[1]; // event emitted 1st param
        bytes32 stage_03_Recipient = Events_Stage[2].topics[2]; // event emitted 2nd param

        assertEq(stage_03_Sender, bytes32(uint256(uint160(address(0))))); // asserting mint from address(0)
        assertEq(stage_03_Recipient, bytes32(uint256(uint160(address(this))))); // asserting 3rd event recipient
    } // forge t --mt test_LogsEventTransfer -vv
}
