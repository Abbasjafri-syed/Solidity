// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ERCtoken} from "../src/ErcToken.sol";

contract TokenERCScript is Script {
    function run() external returns (ERCtoken) {
        vm.startBroadcast(address(this)); // making call with
        ERCtoken mytoken = new ERCtoken(210 ether); // minting tokens
        vm.stopBroadcast();
        return mytoken;
    }
    // forge script TokenERCScript // deployed on anvil
    // forge script TokenERCScript --rpc-url $rpc_url --private-key $pvt_key --broadcast
    // forge script TokenERCScript --f $fork_main_url
}
