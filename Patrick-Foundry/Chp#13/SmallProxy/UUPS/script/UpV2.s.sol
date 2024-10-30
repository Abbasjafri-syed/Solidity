// SPDX-License-Identifier: Non-production
pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {upgradedImplement} from "../src/UpgradeV1.sol";
import {upgradedSecondVersion} from "../src/UpgradeV2.sol";

contract UpgradeSecondScript is Script {
    upgradedSecondVersion secondUpgrade; // pointer to upgradedSecondVersion contract

    function run(address proxyImplement) external returns (address) {
        secondUpgrade = new upgradedSecondVersion(); // deploying contract
        upgradedImplement proxyUp = upgradedImplement(proxyImplement); // proxy casting
        proxyUp.upgradeToAndCall(address(secondUpgrade), ""); // making upgradecall
        return address(proxyUp);
    }
}
