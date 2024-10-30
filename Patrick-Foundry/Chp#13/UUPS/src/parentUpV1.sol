// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract parentVUp is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value; // variable at slot 0

    constructor() {
        _disableInitializers(); // avoid front running of initialzer
    }

    function initializeParent() internal onlyInitializing {
        // initialize function
        __Ownable_init(msg.sender);
    }

    function versionParent() external pure returns (string memory) {
        return "Thy version 2nd Parent";
    }

    function getValued(uint256 slotIndex) external view returns (uint256 storageValue) {
        assembly {
            storageValue := sload(slotIndex) // getting value at given slot
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {} // upgrade function limited to Owner

    uint256[50] __gap; // storage slot for upgrade
}
