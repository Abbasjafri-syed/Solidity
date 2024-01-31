// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {fundContrct} from "../src/practiceCourse.sol";

contract deployemntScript is Script {
    function run() external payable returns (fundContrct) {
        // return the contract
        fundContrct funded = new fundContrct(); // deploying new contract
        return funded; // return the deployed contract
    }

    receive() external payable { // for withdrawing funds from fundContrct contract
        // emit Received(msg.sender, msg.value);
    }
}
