// SPDX-License-Identifier: None

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {ERCNFT} from "../src/NftToken.sol";

contract RecentNft is Script {
    // forge script ERCNFT --rpc-url $rpc_url --private-key $pvt_key --broadcast

    function run() external {
        address most_Recent = DevOpsTools.get_most_recent_deployment("ERCNFT", block.chainid); //get the latest deployed contract
        latest_Deployed(payable(most_Recent)); // calling function and passing address
    }

    function latest_Deployed(address payable most_Recent) public {
        vm.startBroadcast(); // method for deploy
        ERCNFT(payable(most_Recent)).mint_Nft(); // call function of recent deployed
        vm.stopBroadcast(); // stopping broadcast
    }
}
