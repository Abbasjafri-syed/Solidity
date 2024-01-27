// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {fundRecv as fundContrct} from "../src/pricing.sol";
import {deploymentScript} from "../script/price.s.sol";
import {fundInteract} from "../script/interactions.s.sol";

contract CounterTest is Test {
    fundContrct funded; // contract data type

    function setUp() external {
        console2.log(address(funded).balance, "before call");
        deploymentScript deploy = new deploymentScript(); // deploying a new contract through script
        funded = deploy.run(); //caching the deployed contract to var

        console2.log(address(deploy), "setup after");

        console2.log(address(funded), "after call"); // 
        console2.log(msg.sender, "after call"); // sender address

    }

    function test_fundeInteract() external {
        // console2.log(address(funded).balance, "before call");

        fundInteract fundings = new fundInteract();
        fundings.fundingCntrct(address(funded));
        
        console2.log(address(funded), "contract balanceRR");
        assertEq(address(funded).balance, 0.1 ether);
      
    }

    // forge test --mt test_fundeInteract -f $test_rpc_url -vvv

}
