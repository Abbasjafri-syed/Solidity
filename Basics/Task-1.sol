// SPDX-License-Identifier: None

pragma solidity ^0.8.14;

contract Variables {

// types of data in solidity
string public text;
uint256 public blockheight;
address hacker;
address[] public address_exploit; //contract exploited
bool public condition;
bytes32 public tx_hash; //txn hash
mapping(address => uint256) public amount_transferred; //amount stolen


constructor(){
    text = 'This is bnb exploit report';

    blockheight = 21957793;

    hacker = 0x489A8756C18C0b8B24EC2a2b9FF3D4d447F79BEc;

    address_exploit = [0x0000000000000000000000000000000000001004];

    condition = true;

    tx_hash = 0xebf83628ba893d35b496121fb8201666b8e09f3cbadf0e269162baa72efe3b8b;

    amount_transferred[hacker] = 1000000 ;

    }
    }
