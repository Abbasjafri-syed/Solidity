// SPDX-License-Identifier: None

pragma solidity 0.8.19;

import {console, Test} from "forge-std/Test.sol";
import {A, ContractB} from "../src/TryCatch.sol";

contract try_Test is Test {
    A contractA;
    ContractB B_contract;

    function setUp() external {
        contractA = new A();
        B_contract = new ContractB();
    }

    // forge t --mt test_contractAddress -vvv
    function test_contractAddress() external view {
        console.log("contract A:", address(contractA));
        console.log("contract B:", address(B_contract));
    }
// forge t --mt test_emptyRequire -vvv
    function test_emptyRequire() external{
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature('emptyRequire()'));
        console.logBytes(data); // return empty data '0x' similar to empty revert
    }

    // forge t --mt test_requireState -vvv
    function test_requireState() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSelector(contractA.requireState.selector)); // caching return data
        console.logBytes(data); //  require with statement return similar data like revert with string
    }

    // forge t --mt test_emptyRevert -vvv
    function test_emptyRevert() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("emptyRevert()")); // caching return data
        console.logBytes(data); // 0x
    }

    // forge t --mt test_StringRevert -vvv
    function test_StringRevert() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("revertString()")); // caching return data
        console.logBytes(data); // return data of revert with string
            //  0x08c379a <-- function selector
            //  0000000000000000000000000000000000000000000000000000000000000002 <-- location offset
            //  00000000000000000000000000000000000000000000000000000000000000011 <-- string length
            // 726576657274537472696e676d616b6572000000000000000000000000000000 <-- string in hex
    }

    // forge t --mt test_customNoArgs -vvv
    function test_customNoArgs() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSelector(contractA.emptyErrorCheck.selector)); // caching return data
        console.logBytes(data); // return data will be function selector of custom error
    }
     // forge t --mt test_customWithArgs -vvv
    function test_customWithArgs() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature('customErrorCheck()')); // caching return data
        console.logBytes(data); // return data will be function selector of custom error
        console.log('sender', address(this));
    }

    // forge t --mt test_bytesLength -vvv
    function test_bytesLength() external view {
        bytes memory lengther = abi.encode(17);
        console.logBytes(lengther); // 0x
    }

    // forge t --mt test_max -vvv
    function test_max() external {
        uint256 max = type(uint256).max;
        console.log("max", max); //
    }
}
