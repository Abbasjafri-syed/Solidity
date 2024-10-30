// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {implementChild} from "../src/implement.sol";
import {upgradedImplement} from "../src/UpgradeV1.sol";

contract childUpgradeScript is Script {
    upgradedImplement implement_Up; // pointer to upgradedImplement

    function run(address newProxy) external returns (address) {
        implement_Up = new upgradedImplement(); // deploying contract
        implementChild child_Proxy = implementChild(newProxy); // pointing proxy to old implement
        child_Proxy.upgradeToAndCall(address(implement_Up), ""); // calling upgrade function and pointing proxy to new implement
        return address(child_Proxy); // proxy address
    }
}
