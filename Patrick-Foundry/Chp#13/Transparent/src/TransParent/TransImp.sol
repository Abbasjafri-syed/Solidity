// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract TransParentImplement is Initializable {
    uint256 public InitialValue; // setting value may lead to collision

    constructor() {
        _disableInitializers(); // prevent takeover of implementation contract
    }

    function initialize(uint256 _value) external initializer {
        InitialValue = _value;
    }

    function getVersion() external view returns (string memory) {
        return "This is the 1st version";
    }

    uint256[50] __gap; // storage gap
}
