// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Proxy} from "lib/openzeppelin-contracts/contracts/proxy/Proxy.sol";

contract smallProxy is Proxy {
    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // bytes32 private _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1); // expression for above hash generation

    function setImplementation(address newImplement) public {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplement) // storing newImplement address into storage slot
        }
    }

    function _implementation() internal view override returns (address implement_Address) {
        assembly {
            implement_Address := sload(_IMPLEMENTATION_SLOT) // caching value saved at slot
        }
    }

    function getImplmentationAddress() external view returns (address) {
        return _implementation(); // returns address saved into storage slot
    }

    function setValue(uint256 newAdd) external {
        (bool success,) = address(this).call(abi.encodeWithSelector(0xdc3a74b9, newAdd)); // calling function and saving value
        require(success);
    }

    function getValue() external view returns (uint256 value) {
        assembly {
            value := sload(0) // caching value at slot 0
        }
    }
}
