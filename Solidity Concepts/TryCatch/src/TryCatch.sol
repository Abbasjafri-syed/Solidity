// SPDX-License-Identifier: None

pragma solidity ^0.8.19;

import {console} from "forge-std/Test.sol";

interface IA {
    function r_Expected() external returns (uint256); // function expecting return value
}

contract A {
    error errorArgsSender(address caller);
    error errorArgsString(string maker);
    error errorArgsBool(bool maker);
    error errorArgsBytes(bytes maker);

    error emptyError();

    uint256[] unbounded;


function ext_code_size() external view returns (bool) {
        address check = address(1);
        return (check.code.length > 0) ;
    }
    function check_Contract() external view returns (bool) {
        address check = address(1);
        return check.code.length > 0;
    }

    function try_Expected() external pure returns (uint256) {
        uint256 maker = 10;
        return maker;
    }

    function r_Expected() external {
        // return_Expected(); // no return
    }

    function dvdByZero() external pure returns (uint256) {
        uint256 make = 10;
        uint256 take = 5;
        return make / take;
    }

    function bytes_Return() external view {
        bytes memory maker = bytes("datacheck");
        require(msg.sender == address(1), errorArgsBytes(maker));
    } // 0x274e5691

    function outOfGas() external view {
        require(msg.sender == address(1), errorArgsString("revertStringmaker"));
    }

    function arrUnbound() external view returns (uint256) {
        return unbounded[3];
    }

    function falseAssert() external view {
        assert(msg.sender == address(1));
    }

    function requireCustomstring() external view {
        require(msg.sender == address(1), errorArgsString("revertStringmaker"));
    }

    function addr_requireCustomaddr() external view {
        require(msg.sender == address(1), errorArgsSender(msg.sender));
    }

    function bool_requireCustom() external view {
        require(msg.sender == address(1), errorArgsBool(true));
    }

    function requireCustomEmpty() external view {
        require(msg.sender == address(1), emptyError());
    }

    function emptyRequire() external view {
        require(msg.sender == address(1));
    }

    function requireState() external view {
        require(msg.sender == address(1), "revertStringmaker");
    }

    function emptyRevert() external pure {
        revert();
    }

    function revertString() external pure {
        revert("revertStringmaker");
    }

    function emptyErrorCheck() external pure {
        revert emptyError();
    }

    function customErrorCheck() external pure {
        revert errorArgsString("not_Authorised");
    }
}
