// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {parentVUp} from "../src/parentUpV1.sol";

contract upgradedImplement is Initializable, UUPSUpgradeable, OwnableUpgradeable, parentVUp {
    bool public isInitialize; // variable for initialization

/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // avoid front running of initialzer
    }

    function initializeChildUp() external reinitializer(2) {  // cannot be called by script
        super.initializeParent(); // calling parent initializer
        isInitialize = false; // intialized to true
    }

    function versionChild() external pure returns (string memory) {
        return "Thy version 2nd";
    }


    // function _authorizeUpgrade(address newImplementation) internal override onlyOwner {} // upgrade function limited to Owner
}
