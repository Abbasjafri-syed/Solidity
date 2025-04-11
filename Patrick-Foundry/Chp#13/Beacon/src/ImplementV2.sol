// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract ImplementBeaconV2 is Initializable {
    uint256 public vaultUp_Number; // setting value may lead to collision
    string public vaultUp_Name; // setting vault Name

    constructor() {
        _disableInitializers(); // prevent takeover of implementation contract
    }

    function initialize(uint256 _value, string memory _name) external reinitializer(2) {
        vaultUp_Number = _value;
        vaultUp_Name = _name;
    }

    function getVersion() external view returns (string memory) {
        return "This is the 2nd version";
    }

    function valueDec() external {
        require(vaultUp_Number > 0, "Vault Does Not Exist");
        --vaultUp_Number;
    }
}
