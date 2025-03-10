// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract ImplementV2 is Initializable {
    uint256 public SecondSlot; // setting value may lead to collision

    function initialize(uint256 _value) external reinitializer(2) {
        SecondSlot = _value;
    }

    function getVersion() external view returns (string memory) {
        return "This is the 2nd version";
    }

    function valueDec() external {
        --SecondSlot;
    }
}
