// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {parentImplement} from "../src/parentImplement.sol";

contract implementChild is Initializable, UUPSUpgradeable, OwnableUpgradeable, parentImplement {
    bool isInitialized; // variable for initialization

    constructor() {
        _disableInitializers(); // avoid front running of initialzer
    }

    function initializeChild() external initializer {
        super.initializeParent(); // calling parent initializer
        isInitialized = true; // intialized to true
    }

    function versionChild() external pure returns (string memory) {
        return "Thy version Onee";
    }

    function initializeContract() external view returns (bool) {
        return isInitialized;
    }

    // function _authorizeUpgrade(address newImplementation) internal override onlyOwner {} // upgrade function limited to Owner
}
