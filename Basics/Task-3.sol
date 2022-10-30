// SPDX-License-Identifier: No License
pragma solidity ^0.8.14;

contract whiteList{

    address public owner;
    address[] accounts_whiteListed;
    mapping (address => bool) _whiteListed;
   
   constructor () {
       owner = msg.sender;
    }

    //receiving ether and adding users into whiteist
    receive () external payable {
        
        require(msg.value >= 1000, '1000 wei requires to get Whitelisted');

        require(_whiteListed[msg.sender] == false,'Address Already Whitelisted'); //avodiing duplicaion
        
        accounts_whiteListed.push(msg.sender); //pushing sender into array
        
        unchecked{
           
            _whiteListed[msg.sender] =  true; // whitelisting sender
           
            }
        }

    //AirDropping all whitelist simultaneoulsy
    function AirDrop() external {

        for (uint256 i=0; i < accounts_whiteListed.length; i++){
            
            require(msg.sender == owner, 'Owner Function only');
           
            require(_whiteListed[accounts_whiteListed[i]] == true,'Address not Whitelisted'); // optional for better security
            
            uint  amount = address(this).balance / accounts_whiteListed.length ;  //dividng contract balance equally among all sender
            
            payable(accounts_whiteListed[i]).transfer(amount);
            }
        }
    
     }
