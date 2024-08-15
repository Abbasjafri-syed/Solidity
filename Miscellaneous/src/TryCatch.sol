// SPDX-License-Identifier: None

pragma solidity 0.8.19;

import {console} from "forge-std/Test.sol";

contract A {
    error emptyError();
    error errorArgs(address caller);

    function emptyRequire() external view {
        require(msg.sender == address(1));
    }
    function requireState() external view {
        require(msg.sender == address(1), 'revertStringmaker');
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

    function customErrorCheck() external view {
        revert errorArgs(msg.sender);
    }
}

contract ContractB {
    function call_failure(address contractAAddress) external returns (bytes memory) {
        (, bytes memory data) = contractAAddress.call(abi.encodeWithSignature("revertString()"));

        return data;
    }
}
