// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {fundRecv} from "../src/pricing.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {deploymentScript} from "../script/price.s.sol";

contract CounterTest is Test {
    fundRecv funded; // contract data type

    //  generating random address
    address caller = makeAddr("caller"); // random address creation
    address alice = makeAddr("alice");
    uint256 newBalance = 10 ether; // balance allocate through vm.deal or hoax
    uint256 balanceSend = 1 ether;
    uint160 maker = 1234567890; // a number should be saved in uint160 (bytes20) as bytes for each address
    address numAddr = address(maker); // casting number to address to change it to address
    // console2.log(numAddr);

    // deploying the contract
    function setUp() public {
        deploymentScript scriptTest = new deploymentScript(); // deloying new contract
        funded = scriptTest.run(); // saving address on specific chain to contract for interaction

        // method to fund any address generated
        vm.deal(caller, newBalance);
    }

    function test_balance() public {
        assertEq(funded.s_USDValue(), 14e18); // asserting value of var
    }

    // testing balance of new wallet
    function test_balanceAddress() public {
        assertEq(caller.balance, 10e18);
    }

    // testing address of priceFeed
    function test_addFeed() public {
        address valed = address(funded.s_ApriceFeed()); // getting address saved at variable of aggregator
        assertEq(valed, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function test_indexFeed() public {
        address valed = address(funded.addressIndexlength(1)); // getting address saved at given index
        console2.log("The feed address ", valed);
        assertEq(valed, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    // function test_Owner() public {
    //     // assertEq(funded.ownerAccount(), address(this)); // this contract deploying base contract
    //     console2.log(funded.s_ownerAccount());
    //     console2.log(caller);
    //     assertEq(funded.s_ownerAccount(), msg.sender); // wallet deploying contract in setup using script
    // }

    // testing mock contract feed
    function test_feedMock() public {
        uint256 tokenPrice = funded.getFeedPrice(); // getting price of mock contract
        console2.log("The feed Price is:", tokenPrice);
        assertEq(tokenPrice, 2371806800000000000000);
    }
    // 452 998 254 579 861

    function test_feedPrice() public {
        uint256 tokenPrice = funded.tokenPriceFeed(1); // getting price of token at specific index
        console2.log("The feed Price is:", tokenPrice);
        assertEq(tokenPrice, 2210235445050000000000);
    }

    function test_Owner() public {
        address contract_Owner = funded.contractOwner(); //getting address of deployer

        console2.log(address(this));
        // console2.log(address(funded));
        console2.log(msg.sender);
        assertEq(contract_Owner, msg.sender);
    }

    modifier funder() {
        // modifier to avoid redundant code
        // hoax start every time and combine in hoax if balance not given it will set to 2^128
        hoax(caller, newBalance); // cheatcode which combines both prank and deal to start txn with funds..
        funded.deposit{value: balanceSend}(1); // method to transfer funds into contract
        _;
    }

    // method to test deposit funds into account
    function testDeposit() external funder {
        // modidfier already perform deposit txn
        assertEq(funded.userBalance(caller), balanceSend, "balance wrong"); // checking mapping balance of funder

        uint256 startBalance = address(funded).balance; // contract balance
        uint256 OwnerStartBalance = funded.contractOwner().balance; // deployer contract

        vm.prank(funded.contractOwner()); // starting new txn
        funded.withdraw(); // calling withdraw function

        uint256 endBalance = address(funded).balance; // getting contract balance
        uint256 OwnerEndBalance = funded.contractOwner().balance; // getting deployer balance
        assertEq(endBalance, 0); // asserting contract balance
        assertEq(startBalance + OwnerStartBalance, OwnerEndBalance); // asserting deployer balance
    }

    // testing deployer/ caller balance
    function test_ownerBalance() public funder {
        uint256 accBalance = funded.userBalance(caller);
        console2.log(accBalance);
        assertEq(accBalance, balanceSend);
    }

    // testing withdraw function
    function test_WithDrawBalance() public funder {
        uint256 acc_balance = address(funded).balance;
        // console2.log(acc_balance);

        assertEq(acc_balance, balanceSend); // checking address of account with amount sent

        uint256 gasStart = gasleft(); // methd to know gas used when txn is carried out
        console2.log("this is start gas:", gasStart);
        vm.txGasPrice(1); // method to simulate vm gas price
        vm.prank(funded.contractOwner()); // starting call from owner
        funded.withdraw(); // calling function
        uint256 gasEnd = gasleft();
        uint256 gasDiff = (gasStart - gasEnd) * tx.gasprice;
        console2.log("this is gas diff:", gasDiff);

        assertEq(address(funded).balance, 0); // checking address after withdrawal
    }

    // method testing for deposit and refund excess amount
    function test_DepositFund() external {
        hoax(caller, newBalance); // starting call with balance
        uint256 amountTransfer = 6226863864921888; // amount refund depends on eth price

        funded.depositFund{value: balanceSend}(1); // deposit funds with eth
        uint256 userbalance = funded.userBalance(caller); // caching funder amount
        uint256 refundAmount = balanceSend - userbalance; // caching amount to be refunded
        console2.log(refundAmount);

        assertEq(caller.balance + amountTransfer, 10 ether); // asserting caller balance and amount trsfer
        assertEq(userbalance, amountTransfer); // asserting user balance with amount transfer
        assertEq(address(funded).balance, amountTransfer); // asserting contract balance with amount funded
    }

    // testing multiple fundng
    function test_DepositMultiple() external {
        uint256 funderCount = 19; // number of funder

        for (uint160 i; i < funderCount; ++i) {
            // loop to allow multiple funding
            hoax(address(i), newBalance); // starting txn with balance
            // console2.log(address(i));
            funded.deposit{value: balanceSend}(1); // depositing specific tokens
        }

        assertEq(address(funded).balance, 19 ether); // asserting account balance with amount funded
    }

    // testing multiple funding and withdraw
    function test_DepositMultiplenWithdraw() external {
        // same as above
        uint256 funderCount = 19;

        for (uint160 i; i < funderCount; ++i) {
            // loop to fund address as per funder count
            hoax(address(i), newBalance); //  start call with every caller and giving them fund
            funded.deposit{value: balanceSend}(1); // deposit value to contract
        }

        // starting call
        vm.prank(caller);
        // uint amounter = uint(84992522131502854301067185853) / 1e18;
        // console2.log(amounter);
        // console2.log(msg.sender.balance);
        console2.log(msg.sender);
        // console2.log(address(funded).balance);
        console2.log(address(this));
        funded.withdraw(); // calling withdraw function
        console2.log(funded.contractOwner().balance);
        console2.log(funded.contractOwner());

        assertEq(address(funded).balance, 0); // checking contract balance after withdraw
        assertEq(caller.balance, 29 ether); // checking caller balance
    }

    // testing address at given index
    function test_addressAtIndex(uint256 addIndex) external {
        address indexFunded = address(funded.addressIndexlength(addIndex)); // casting aggregator type to address
        assertEq(indexFunded, 0xc59E3633BAAC79493d908e63626716e204A45EdF);
    }

    // testing price of token at given address at index
    function test_tokenAtIndex() external {
        uint256 tokenAtIndex = funded.tokenAtIndex(2, 0x694AA1769357215DE4FAC081bf1f309aDC325306); // casting aggregator type to address
        assertEq(tokenAtIndex, 2274040000000000000000);
    }

    // testing price of eth token
    function test_tokenPriceFeed() external {
        uint256 tokenAtIndex = funded.tokenPriceFeed(1); // casting aggregator type to address
        assertEq(tokenAtIndex, 2314617407000000000000);
    }

    // forge test -f $test_rpc_url -vvv --mt test_tokenAtIndex()

    // modifier onlyOwner() {
    //    require(funded.contractOwner() == msg.sender, 'onlyOwner can send txn');
    //    _;
    // }

    //  function test_fundDeposit() public {
    //     vm.prank(caller);
    //     funded.depositFund{value: balanceSend}(1);

    //     // amount save inside mapping userBalance
    //     uint amountSent = funded.userBalance(caller);
    //     console2.log('This is user balance',amountSent);

    //     // test fail as amount is refunded for excessive amount sent
    //     assertEq(amountSent, balanceSend);
    // }

    // function test_deposit() public {
    //     vm.prank(caller);
    //     vm.expectRevert();
    //     funded.deposit{value: balanceSend}(11);

    //     // amount save inside mapping userBalance
    //     uint amountSent = funded.userBalance(caller);
    //     console2.log('This is user balance',amountSent);

    //     // test fail as amount is refunded for excessive amount sent

    //     assertEq(caller.balance, 10 ether);
    // }

    // function test_withdraw() public {
    //     vm.prank(caller);
    //     funded.deposit{value: balanceSend}(1);
    //     uint accountBalanceStart = address(funded).balance;
    //     console2.log('This is account balance', accountBalanceStart);

    //     vm.prank(caller);
    //     // vm.expectRevert();
    //     funded.withdraw();
    //     uint accountBalanceEnd = address(funded).balance;
    //     console2.log('This is account balance end', accountBalanceEnd);

    //     // amount save inside mapping userBalance
    //     // uint userbalance = caller.balance + accountBalance;

    //     // test fail as amount is refunded for excessive amount sent
    //     assertEq(accountBalanceEnd, 0 ether, 'no balance left');
    // }

    // forge test --fork-url $test_rpc_url -vvv --mt test_deposit

}
