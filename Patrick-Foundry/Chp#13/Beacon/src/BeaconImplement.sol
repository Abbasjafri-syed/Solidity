// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract beacon_Implement is Initializable {
    uint256 public vault_Number; // setting value may lead to collision
    string public vault_Name; // setting vault Name

    constructor() {
        _disableInitializers(); // prevent takeover of implementation contract
    }

    function initialize(uint256 _value, string memory _name) external initializer {
        vault_Number = _value;
        vault_Name = _name;
    }

    function getVersion() external view returns (string memory) {
        return "This is the 1st version";
    }
}
