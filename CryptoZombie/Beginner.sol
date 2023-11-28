// SPDX-License-Identifier: None

pragma solidity 0.8.19;
// pragma solidity >=0.5.0 <0.6.0;

import "./safemath.sol";


contract otc {
  // (+*"") () { } ?!><

  using SafeMath for uint256;
  uint public dna = 1e20; //  same is 10 ** 20 as it 20 zero after 1
  uint public dnam = 10 ** 20;

  struct making{  // struct to store data have storage data type
      string name;
      uint dna;
      uint idCount;
      uint level; // to increase level
      uint time;
  }
  
  making[] public maker; // storage pointer towards struct in array
  mapping(address => uint) public ids; // mpping for storing ids for a address
  mapping(uint => address) public idOwner; // storing ownership for every id
  mapping(uint => uint) public timed; // storing time
  mapping(address => making) public timers; // storing time
  mapping(uint => address) public approval;

// errors
error timeLocked();
error limitReached(string);

  uint peck; // id for each time
  making makeID; // storage pointer for struct
  uint feesWei = 100;
  
  function idMaker(string calldata bekr) external payable { // function to allow a user 3 ids with 1 min gap
    require(msg.value >= feesWei , 'required 100 wei to mint'); // condition to pay for id generation 
    if (msg.value > feesWei) {
     uint refund = msg.value - feesWei; // returning value if > fees threshold
     (bool success, ) = msg.sender.call{value: refund}(""); // low level call checking
     require(success, "Transfer failed."); // checking value returned
      } 
    uint timeLimit = block.timestamp; // assigning time to a var
    timed[peck] = timeLimit; // assigning time to mapping
    if (ids[msg.sender] >= 1) { // checking if id is 1 or greater
    if (ids[msg.sender] >= 3) { // checking id to be 3 
    revert limitReached('You have reached your limit'); // revert when id reached 3
  }
  require (timed[peck] > (makeID.time + 5 seconds), ' Wait for 05 seconds'); // cei for having a timelimite as min delay with last id time
  }
  makeID.time = timeLimit; // time to pointer
  ++peck; // increment id for time
  maker.push(making(bekr, hash(bekr), ++ids[msg.sender], 1, (makeID.time))); // pushing data to array
  uint lengthen =  maker.length; // number of each id
  idOwner[lengthen] = msg.sender;  // allocate number to each id
}

function levelUp(uint id) external payable {
  require(idOwner[id] == msg.sender, 'You are not owner');
  require(msg.value == 1000 wei , 'required 1000 wei to upgrade');
  uint num = id - 1 ;
  making storage leveled = maker[num];
  // if (leveled.idCount == id){ // 10489 gas
    leveled.level++;
    // }
}

function hash(string memory name) internal view returns (uint) { 
        uint pecks = uint(keccak256(abi.encode(name))); // generating hash for string
        return pecks % dna; // returing result of last 20 digits
}

function getIdsByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ids[_owner]); // storing wallet ids
    uint counter;
    for (uint i; i < maker.length; ++i) { // check every array
      if (idOwner[i] == _owner) { // every index own by wallet
      result[counter] = i; // storing id at index
      ++counter; // incremenet  index
      }
      }
    return result; // all result of ids owned
  }

  function withdraw() external {
    payable(msg.sender).transfer(address(this).balance); // transfering all balance of contract to caller. 
    }

  function transferID(address to, uint tokenID) external {
    require(approval[tokenID] == msg.sender && idOwner[tokenID] != to, 'You are not approved'); // checking caller is approved to transfer and not sent them back... 
    idOwner[tokenID] = msg.sender; // changing owner to approver
    ++ids[msg.sender]; // add token id to approver
    --ids[to]; // sub the token id from owner
    }
    
  function transferapproval(address to, uint tokenID) external {
     require(idOwner[tokenID] == msg.sender && to != msg.sender, 'You are not owner'); // checks for caller is owner and not approved itself
     approval[tokenID] = to; // approving id for transfer
    }

 uint randNonce;

  function randMod(uint _modulus) external returns(uint) { // random numbe generator
    ++randNonce; // nonce
    return uint(keccak256(abi.encode(block.timestamp, msg.sender, randNonce))) % _modulus; // random number generate as all args will be different
  }

uint public time = block.timestamp; // time stored during deployment 

modifier timelock() {
// require(block.timestamp > time, 'wait for time to passed'); // check currentmtime to be more than deployed
  if (block.timestamp <= time){ // if checked current time to be less than deployed
    revert timeLocked();
    }
    _;
    }

modifier checkinput(uint num) { // modiifier for validating value is within limite
require(num < 1000, 'value exceeed limit'); // check currentmtime to be more than deployed
    _;
    }

uint public a;

function doing(uint c) external checkinput(c) returns (uint loop, uint) { // function checking do while loop
  uint b = 1e3; // number is 1k
  do { // carry out this if while is true
    a = b + c;
    ++c; // incrment value of of c 
    ++loop; // increment loop if 
    } while (c < b); // checking condition
    return (loop, a); // return value whne true
        }

 string blet = 'krill';  // state variable
  function storing() external view returns (string memory) { // gas bad
    return blet; //returning a state variable
      }

  function memoring() external view returns (string memory){ // gas efficient
    string memory b = blet; //creating a stack variable to store state var
    return b; // returning stack
      }


  function whiled(uint c) external {
    uint b = 1e3;
    uint loop;
    while (b > c){ // while loop iteration when condition is true
      a = b + c;
      c++;
      ++loop;
      }
      }

function underFlow(uint8 k) external pure returns (uint16) {
  unchecked {
        uint8 c = k / 2;
        return c;
        }
       }

function times() external view returns (uint) {
        return block.timestamp;
       }

function lengthy(string memory name) external view timelock returns (uint) {
    uint later = 1 minutes + time;
    if (block.timestamp > later ) {
        return bytes(name).length; // 
       }
else {
    return 1;
}
}

function length(string memory name) external pure returns (uint) { 
        uint lamp = bytes(name).length;
       return lamp;
}
function numlength(uint num) external view returns (uint) { 
              return num % dna;
}

function createDna(string memory name) external returns (uint) { 
       uint hashing = hash(name);
      maker.push(making(name, hashing, ++ids[msg.sender], 1, block.timestamp));
      uint id = maker.length;
      idOwner[id] = msg.sender;
      return id;
      
}
  }
