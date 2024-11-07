// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract upgradedSecondVersion is UUPSUpgradeable, OwnableUpgradeable {
    bool public isInitialize; // variable for initialization

    function versionChild() external pure returns (string memory) {
        return "Thy version Upgraded_Lastly";
    }
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {} // upgrade function limited to Owner
}
