// SPDX-License-Identifier: None

pragma solidity ^0.8.19;

import {ERCNFT} from "../src/NftToken.sol";
import {Script} from "forge-std/Script.sol";

contract NFT721Deploy is Script {
    // main method for script to deploy contract
    // forge script NFT721Deploy --rpc-url $rpc_url --private-key $pvt_key --broadcast // script for deployment

    function run() external returns (ERCNFT) {
        vm.startBroadcast(address(this));
        ERCNFT NFT_deployer = new ERCNFT(); // deploying contract and caching
        vm.stopBroadcast();

        return NFT_deployer; // returning addresss deployed
    }

    receive() external payable {}
}
