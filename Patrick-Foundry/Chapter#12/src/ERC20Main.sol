// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {ERC20Burnable, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DcentralStable is ERC20Burnable, Ownable {
    constructor() Ownable(msg.sender) ERC20("DcentralStable", "DSC") {}

    error zeroValue();
    error zeroAddr();
    error InsufficientBalance();

    // burn functionality
    function burn(uint256 amount) public override onlyOwner {
        if (amount == 0) revert zeroValue(); // sanity check
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();
        super.burn(amount); // call burn function
    }

    // mint functionality
    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
        if (to == address(0)) revert zeroAddr(); // sanity check
        if (amount == 0) revert zeroValue(); // sanity check
        _mint(to, amount); // mint amount to sender
        return true;
    }
}
