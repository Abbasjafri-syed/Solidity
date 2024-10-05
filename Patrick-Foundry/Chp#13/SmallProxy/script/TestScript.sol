// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {smallProxy} from "../src/smallProxy.sol";
import {Implement} from "../src/Implement.sol";

contract Test_Script is Script {
    Implement Implement_Contract; // implement pointer
    smallProxy Proxy_Contract; // Proxy pointer

    function run() public returns (Implement, smallProxy) {
        Implement_Contract = new Implement(); // deploying contract
        Proxy_Contract = new smallProxy(); // deploying contract

        return (Implement_Contract, Proxy_Contract); // return contract
    }
}
