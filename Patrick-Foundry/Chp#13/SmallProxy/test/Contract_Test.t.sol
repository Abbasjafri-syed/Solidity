// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Test_Script} from "../script/TestScript.sol";
import {smallProxy} from "../src/smallProxy.sol";
import {Implement} from "../src/Implement.sol";

contract CounterTest is Test {
    Test_Script test_Script; // script pointer

    Implement Implement_Contract; // implement pointer
    smallProxy Proxy_Contract; // Proxy pointer

    function setUp() public {
        test_Script = new Test_Script(); // deploying contract
        (Implement_Contract, Proxy_Contract) = test_Script.run(); // assigning contract to Tester
    }

    // forge t --mt test_ContractInfo -vvv
    function test_ContractInfo() external view {
        console.log("Implement Contract:", address(Implement_Contract));
        console.log("Proxy Contract:", address(Proxy_Contract));
    }

    // forge t --mt test_setImplement -vvv
    function test_setImplement() internal {
        Proxy_Contract.setImplementation(address(Implement_Contract)); // calling proxy contract function and passing implementation
        address implnt = Proxy_Contract.getImplmentationAddress(); // caching implementation contract

        // console.log("Implmentation Address:", implnt); logging address
        assertEq(implnt, address(Implement_Contract)); // matching address
    }

    // forge t --mt test_Storage -vvv
    function test_Storage() external {
        test_setImplement(); // calling function
        Proxy_Contract.setValue((1)); // setting value through delegate call
        uint256 addr = Proxy_Contract.getValue(); // caching value
        console.log("Value set:", addr); // logging value
        assertEq(addr, 1); // matching value set
    }
}
