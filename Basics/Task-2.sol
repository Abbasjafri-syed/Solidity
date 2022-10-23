// SPDX-License-Identifier: No License
pragma solidity ^0.8.14;

contract abc{

    address public owner;
    address[] accounts;
   
    mapping (address => bool) _blacklisted;

    constructor(){
        owner = msg.sender;
    }

// Blacklist single address
 function blackList(address _addr) internal {
        _blacklisted[_addr] = true;
    }
  
// Blacklist multiple address using loop

function bulk_blacklisted(address[] memory users) internal {
       for (uint256 i=0; i < users.length; i++){
        _blacklisted[users[i]] =  true;
        // users[i].push(accounts);  // need solution
         }
    }

    // Adding address from external function
    function add_blackList(address[] memory _addr)external{
        require(msg.sender == owner, 'Owner Function only');
        bulk_blacklisted(_addr);
    }

    // checking adddress status either blacklisted or not
    function check_status(address addr) external view returns (bool){
        if(_blacklisted[addr]){
            return true;
        }
        else{
            return false;
        }
        // (_blacklisted[addr] == true ? return true :  return false ); //need solution
         }
} 
