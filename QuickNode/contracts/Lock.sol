// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Governance_Token is ERC20 {
    address[] accounts_whiteListed;
    mapping(address => bool) _whiteList;

    constructor(string memory _name, string memory _symbol)
        ERC20(_name , _symbol)
    { }
// Contract is deployed on Goerli Network at Address: 0x5c1Dd55579e1Bf31b46F26D52E8906F61F8dBF00


    //receiving ether and adding users into whitelist
    receive() external payable {
        require(
            msg.value >= 100,
            "100 or more wei requires to get Whitelisted"
        );

        require(_whiteList[msg.sender] == false, "Address Already Whitelisted"); //avoiding duplicaion of whitelisting

        accounts_whiteListed.push(msg.sender); //pushing sender into array for later used like Airdrop...

        unchecked {
            _whiteList[msg.sender] = true; // whitelisting sender to become eligible for different areas like voting in DAO proposal or pre-sale...
        }
    }
}
