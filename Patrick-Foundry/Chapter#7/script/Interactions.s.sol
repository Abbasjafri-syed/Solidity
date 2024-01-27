// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol"; // cyfrin devops
import {fundRecv as fundContrct} from "../src/pricing.sol";


contract fundInteract is Script {


    function fundingCntrct(address latestContract) public {
        // method for funding contract using script
        vm.startBroadcast();
        fundContrct((latestContract)).deposit{value: 0.1 ether}(1); // calling deposit function in fundContrct 
        vm.stopBroadcast();
    }

    function run() external {
        // method to get the latest contract deployed
        address latestContract = DevOpsTools.get_most_recent_deployment("fundContrct", block.chainid);
        fundingCntrct(latestContract); // calling function to deposit
    }

    // forge test --mt test_fundeInteract -f $test_rpc_url -vvv
}
