// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Implement { // implementation contract
    uint256 public maker; // storage slot 0

    function set_Maker(uint256 value) public {
        maker = value; // setting value
    }
}
