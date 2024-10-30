// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {implementChild} from "../src/implement.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract childImplementScript is Script {
    implementChild child_Implment; // pointer to implementChild

    function run() external returns (address) {
        child_Implment = new implementChild(); // deploying contract
        ERC1967Proxy proxy = new ERC1967Proxy(address(child_Implment), ""); // deplying proxy and pointing to implement
        return address(proxy); // proxy address
    }
}
