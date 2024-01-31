# Crypto-Zombies

1.	Fixed length array uint [5] arr; length cannot be increase.
2.	Array  variable can be limited like address[] memory pools = new address[](2); .
3.	Variable 2 types i.e., value and reference. https://www.geeksforgeeks.org/solidity-types/
4.	Encoding is done using keccak256 which expect single arg in bytes. https://cryptozombies.io/en/lesson/1/chapter/11
5.	Hash of specific length can be attained using modulo i.e.; hash % (10 ** length).
6.	Modulo only works for uint/int data type.
7.	Key can be incremented for mapping like mapping[key]++; .
8.	Renounce ownership is setting owner to address(0) which cannot be called anymore. https://cryptozombies.io/en/lesson/3/chapter/2
9.	Better to emit event just before changes takes place.
10.	If file is imported all contracts will be inherited, if a specific contract is called then it will be inherited then.
11.	Inheritance rule is followed from origin if a base contract inherits a contract it can be inherited to every other contract that inherits base contract.
12.	Inheritance depends on import..import is linking file name, inheritance is linking with contract name.
13.	Use smallest integers inside struct for minimum storage space.
14.	Storage pointer can be used as arg inside a internal or private function.
15.	Identical data types packing cost less gas as they are clustered together. https://cryptozombies.io/en/lesson/3/chapter/4
16.	Uint default return value is 256 bits.
17.	Tuple are structs which requires input value to be passed with same arguments numbers as in struct. https://remix-ide.readthedocs.io/en/latest/udapp.html#passing-in-a-tuple-or-a-struct-to-a-function
18.	Calldata is for external functions while memory is for internal. View functions are gas free for external function.
19.	Storage operations are most expensive mainly for writing.
20.	Memory arrays are created with fixed length as they cannot be resize by using push method.
21.	Memory array inside external function with view attribute built with for loop is overall cheap in terms of gas.
22.	Bytes(str).length method for knowing string length.
23.	Functions in interface should be of same name with return value to be placed in order according to the main contract(same applied to implementing contracts.
24.	keccak data type is bytes32...abi. datatype is bytes with storage as memory or calldata.
25.	The ‘unchecked’ keyword is used for particular operation without any checks. When ‘unchecked’ is used, Solidity skips these default checks and assumes that the operation will not result in any issues.
26.	Unchecked can cause arithmetic over and underflow and should be used cautiously.
27.	Require and if condition works in an opposite way (mainly for the relational operators).
28.	View functions don't cost any gas when they're called externally. View function when called by a non-view function internally within a contract cost gas.
29.	Overflows occur when the value to be represented exceeds the range of values representable by a given type. The integer overflow occurs when a number is greater than the maximum value the data type can hold. Uint8 = max[255] + 1 overflow leads to 0, Uint8 = min[0 ] - 1  overflow leads to 255 as it is a –ve overflow.
30.	Underflows occur when the precision a type offers isn't enough to fully represent the result of an operation. The integer underflow occurs when a number is smaller than the minimum value the data type can hold. Underflow example is when denom is smaller than numerator 3/2.
31.	new uint[](3); means initiating an array with length 3. Values are assigned as values[0] = 1;
32.	An array can be build inside a view function with memory pointer which make it retrieving data without any spending any gas.
33.	Code ordering is important in making logic to be strong.
34.	The keyword block.timestamp is constant as storage variable in contract but updated when called within a function.
35.	To pass message in error function string keyword must be declared inside error thisError(string).
36.	Modifiers are of 4 types i.e., visibility, state, custom and payable. Visibility is pvt, public, internal and external; state are view and pure; and custom are defined inside contracts. Payable modifier provides function with ability to receive ether.
37.	 Ether can only be transfer to a payable address.
38.	 Send and transfer are carried out using ( ) while call is done through call{value: msg.value}(" "); for transferring ether.
39.	call{value: msg.value}(" "); msg.value is the amount transfer while (" "); is checking return value. https://consensys.io/diligence/blog/2019/09/stop-using-soliditys-transfer-now/
40.	.call( )  is prone to reentrancy and should be used with caution.
41.	In solidity 0.8 and above transfer to caller is like this payable(msg.sender).transfer(address( this) .balance).
42.	Random values can be created in solidity using this keccak256(abi.encode(block.timestamp, msg.sender, randNonce))), this is due to all params will be different. 
43.	% _modulus will limit number of number generated like for 100 it will give number from 1-99.
44.	Always put condition first in require that have higher computation process i.e., if (ids[msg.sender] == id) as this save gas.
45.	Redundant condition can be used as modifier for better access control.
46.	Memory pointer does not write to state variables. Memory pointer has block scope. Always use storage pointer to write data on state variables.
47.	Implementing a contract is linked to creating its interface which includes all functions and events. Then it is inherited in the contract. Functions in interface have external visibility with name to remain same.
48.	Function and modifier cannot have similar name and will lead to error.
49.	Mapping[num] =  address; is the method to change address of a mapping.
50.	Library is a contract that is attached to functions with specific  data type i.e.,  using library for data type. Library must be linked with the contract either making it internal to file or import.
51.	An argument can be passed to an function through variable with accessing  i.e.; uint test = 2; test = test.mul(3);.
52.	require  refund the rest of gas when a function fails, whereas assert not.
53.	Safemath method can be instead of decrement or increment like instead maker++ use maker.add(1).
54.	Natspec are comments with different  tags like author, dev, title, param, audit etc.
 
# Patrick-Foundry - solidity


1.	Bytes and bytes32 have different bytes values in solidity.
2.	Strings are converted to bytes.
3.	View function does not allow state change. They are gas less and will cost gas only when they are called by another function internally.
4.	Struct are custom data type that can have different data types in its. Structs are declared with pointers according to need. 
5.	Values can be passed simply according to data location or json key pair value.
6.	Datatype also need to be declared while passing values.
7.	Array declared with data types are dynamic i.e., struct[] arr. Static array are defining number of values during declaration struct[5] arr.
8.	10 ** 18 and 1e18 is same thing. 
9.	Struct[index].datatype is method to read value inside of struct at a given index.
10.	keccak256(abi.encode(string ) is method to convert string into bytes.
11.	6 areas evm store information i.e.; storage, memory, call data, code, stack and logs[events].
12.	Calldata and memory are temporary storage executed during function.
13.	Calldata cannot be modified. Storage and memory data types can be modified.
14.	Data storage are defined for struct, arrays and string.
15.	Same return type should be declared in returns in which data is stored i.e.; simpleContract myContract should return simpleContract;.
16.	Chainlink price feed return 8 decimal which can be converted to 18 using the method...return uint256(price * 1e10).
17.	Multiple input can be added to array variable using loops.
18.	arrVar = new array[](0); is the method to delete every index of array.
19.	Value increment in mapping should be use with +=  i.e.; map[address] += uint;
20.	Modifier should be used if same condition have to be applied to different function.
21.	Custom error an also be used instead of require condition.
22.	Multiplication should always be carried out before division with also ensuring denominator is lower than numerator.
23.	Transferring amount are carried out using transfer, send and call method.
24.	Transfer and send have 2300 gas limit. Transfer throws error if txn need more than 2300 gas, Call fwd all the gas
25.	Send and call method are low level calls which return bool value used to check for revert.
26.	.call method is used to call function of contract `.call("")`.
27.	 Receive and fallback functions are used to receive ether on contract. Fallback is called when no function with specific name exist and some data is sent with ether.
28.	Libraries cannot be inherited. Libraries are used inside contract for specific data type i.e., ‘using library for uint’.
29.	 When using a function of library inside a contract, its first parameter must be the data type for which it is used.
30.	dynamic datatypes (bytes, string or array) are not use with  calldata instead we use the memory keyword.
31.	calldata is a read-only temporary memory location that holds the function arguments sent to the function by the caller (EOA or another smart contract). You cannot instantiate calldata in the contract.
32.	Amount in wei * tokenPrice / 1e18 gets the token value in decimal[USD].
33.	Amount in wei * 1e18  / tokenPrice  gets the token value in ether.
34.	Struct with mappings cannot have pointers in memory.
35.	Updating time variables through function should be carried out in last to avoid collision with condition to check for time.
36.	In require condition the value which is target(influence the state change) should come first i.e.; require(block.timestamp > timeLimit).
37.	Script contract must have run(), and test must have setup() as the first function.
38.	Test  contract should inherit script as well as the main contract.
39.	Struct does not allow mapping and array in it.... https://github.com/ethereum/solidity/issues/12302 
40.	Constructor cannot have visibility but can be mark payable.
 
# Foundry-test
### https://github.com/Cyfrin/foundry-full-course-f23#lesson-7-foundry-fund-me

1.	Foundry install on windows using git...guide YT smart contract programmer...’foundryup’ inside git install foundry on windows.
2.	forge init is used to start a new project...forge build or compile for compiling contract.
3.	In foundry contract are deployed locally on anvil. Anvil is local blockchain like ganache.
4.	Forge create take contract name not contract file. Anvil needs to be run before contract deployment.
5.	forge create contractName –private-key is command-line `CL` to deploy contract in foundry.
6.	Forge create contractName –interactive is used to insert pvt key without showing.
7.	forge create contractName --rpc-url $test_rpc_url --private-key $test_pvt_key --constructor-args constructor arguments is the method to deploy contract with constructor .
8.	Contract also can be deployed using script by writing script in script folder.
9.	The main function in script is `run` which have the code for deployment. The contract file is imported and then the contract is deployed and saved as contract type variable which is returned.
10.	To deploy contract onchain `forge script script/contract --rpc-url –broadcast –private-key` is the CL using script. 
11.	Create method to deploy contract onchain is linked to forge Contractname --rpc-url –broadcast –private-key` `` option.
12.	Adding variables in .env file shouldn’t have gap b/w var name and values like `varName=0x512`
13.	 `source .env` is means to add .env into source file.
14.	  To call value from .env file they should be with `$` sign without any gap in between.
15.	 Broadcast is only used with script and not with create method. It requires pvtkey for wallet
16.	–rpc-url is means to deploy on chain..in script deployment does not need pvt key with rpc but with create it need –private-key as well.
17.	 Forge clean remove the `out` folder.
18.	 `Cast to-base` is method to convert values.
19.	 Cast is also used to interact with a deployed contract using CL `cast send contractAddress ‘’functionName(uint param)’’ args123
20.	Cast call can be made to check on result for a write function as a static call.
21.	  `cast call contractAddress "func(argumentuint256)" --rpc-url ` is the syntax to use for making call on-chain.
22.	 ‘vm’ cheat code ignore the next line if also the ‘vm’ is present.
23.	Vm.prank(caller) method is used to initiate txn with specific addres instead of msg.sender or address (this).
24.	Vm.deal(caller, 1 ether)  is used to fund the contract with required amount.
25.	hoax(caller, 1 ether)  is combination of both prank and deal.
26.	If an amount is to be sent for a payable contract it is called like a low level call. i.e.; contract.function{value: amount}();
27.	–f is short form of –fork-url and doesn’t work with local host...only with testnet or mainnet.
28.	Calling elements of array in test are done by caching them in array and calling each element separately (address[] memory fuser = (funded.getFunders());assertEq(fuser[0], caller));)or through loop.
29.	Testing needs to be developed around 3 A’s i.e. Arrange, Act and Assert.
30.	Arrange is setting all parameters and initial state of all variables...Act is calling the contract or method in contract...assert is validating state changes taken place in Act.
31.	Branching tree Technique or BTT is method for organising unit testing based on state changing taken place at each step.
32.	BTT starts with default behaviour of contract and then modifier are created and added before each state changing.
33.	 Vm.warp() is the cheat code to create a time difference between two txns. By default it is 1 i.e., vm.warp(block.timestamp) is 1.
34.	 Receive and fallback is must for contract receiving native token...payable function does not provide contract with ability to receive ether.

 





