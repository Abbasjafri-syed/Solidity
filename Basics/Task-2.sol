// SPDX-License-Identifier: No License
pragma solidity ^0.8.14;

contract Blacklist{

    address public owner;
    address[] accounts_blacklisted;
    mapping (address => bool) _blacklisted;
   
    constructor(){
        owner = msg.sender;
    }
  
// Blacklist multiple address using loop

function bulk_blacklisted(address[] memory users) internal {
       for (uint256 i=0; i < users.length; i++){
        _blacklisted[users[i]] =  true;
        unchecked{
        accounts_blacklisted.push(users[i]);
         }         }
    }

    // Adding addresses into blacklist Array from external function
    function add_blackList(address[] memory _addr)external{
        require(msg.sender == owner, 'Owner Function only');
        bulk_blacklisted(_addr);
    }

    // checking adddress status either "blacklisted" or not
    function check_status(address addr) external view returns (bool){
        if(_blacklisted[addr]){
            return true;
        }
        else{
            return false;
        }
        // (_blacklisted[addr] == true ? true : false); //need solution
         }

    // Checking number of accounts in blacklist array
    function Total_Addressesblacklisted() external view returns (uint){
        return accounts_blacklisted.length;
    }

}
