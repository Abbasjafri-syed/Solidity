// SPDX-License-Identifier: None

pragma solidity ^0.8.19;

import {console, Test} from "forge-std/Test.sol";
import {Malicious_Contract} from "../src/Tester.sol";

contract Malicious_Contract is Test {
    Malicious_Contract contractA; // pointer to malicious contract 

    function setUp() external {
        contractA = new Malicious_Contract(); // deploying malicious contract 
    }

    // forge t --mt test_contractAddress -vvv
    function test_contractAddress() external view {
        console.log("contract A:", address(contractA)); // logging contract address
    }

    // forge t --mt test_bytes_Return -vvv
    function test_bytes_Return() external {
        (, bytes memory err) = address(contractA).call(abi.encodeWithSignature("bytes_Return()"));
        console.log("bytes_Return length:", err.length); // logging return data length
        // console.logBytes(err); // logging return data 
    }

        // forge t --mt test_externalCall -vvv
    function test_externalCall() external {
        bytes memory packer = abi.encode("datacheck"); // bytes data sent
        
        (bool success, bytes memory response) = address(contractA).call(packer); // making low level call and passing data
        uint256 balance = address(msg.sender).balance;

        console.log("Bytes response:", response.length); // logging return data length
        console.logBytes(response); // logging return data in byte value
    }

    }
