// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC20Vote.sol";

contract Whitelisting is ERC20Vote {
    address[] accounts_whiteListed;
    mapping(address => bool) _whiteListed;

    constructor(string memory _name, string memory _symbol)
        ERC20Vote(_name, _symbol)
    {}

    //receiving ether and adding users into whiteist
    receive() external payable {
        require(msg.value >= 1000, "1000 wei requires to get Whitelisted");

        require(
            _whiteListed[msg.sender] == false,
            "Address Already Whitelisted"
        ); //avodiing duplicaion for already whitelisted address

        accounts_whiteListed.push(msg.sender); //pushing sender into array for later used like Airdropping

        unchecked {
            _whiteListed[msg.sender] = true; // whitelisting sender
        }
    }
}
