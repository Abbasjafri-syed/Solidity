# Solidity
Solidity learning basic to advance

# Crypto-Zombies

1.	Fixed length array uint [5] arr; length cannot be increase.
2.	Variable 2 types i.e., value and reference. https://www.geeksforgeeks.org/solidity-types/
3.	Encoding is done using keccak256 which expect single arg in bytes. https://cryptozombies.io/en/lesson/1/chapter/11
4.	Hash of specific length can be attained using modulo i.e.; hash % (10 ** length).
5.	Modulo only works for uint/int data type.
6.	Key can be incremented for mapping like mapping[key]++; .
7.	Renounce ownership is setting owner to address(0) which cannot be called anymore. https://cryptozombies.io/en/lesson/3/chapter/2
8.	Better to emit event just before changes takes place.
9.	If file is imported all contracts will be inherited, if a specific contract is called then it will be inherited then.
10.	Inheritance rule is followed from origin if a base contract inherits a contract it can be called to every function that inherits base contract.
11.	Inheritance depends on import..import is linking file name, inheritance is linking with contract name.
12.	Use smallest integers inside struct for minimum storage space.
13.	Storage pointer can be used as arg inside a internal or private function.
14.	Identical data types packing cost less gas as they are clustered together. https://cryptozombies.io/en/lesson/3/chapter/4
15.	Uint default return value is 256 bits.
16.	Tuple are structs which requires input value to be passed with same arguments numbers as in struct. https://remix-ide.readthedocs.io/en/latest/udapp.html#passing-in-a-tuple-or-a-struct-to-a-function
17.	Calldata is for external functions while memory is for internal. View functions are gas free for external function.
18.	Storage operations are most expensive mainly for writing.
19.	Memory arrays are created with fixed length as they cannot be resize by using push method.
20.	Memory array inside external function with view attribute built with for loop is overall cheap in terms of gas.
21.	Bytes(str).length method for knowing string length.
22.	Functions in interface should be of same name with return value to be placed in order according to the main contract(same applied to implementing contracts.
23.	keccak data type is bytes32...abi. datatype is bytes with storage as memory or calldata.
24.	The ‘unchecked’ keyword is used for particular operation without any checks. When ‘unchecked’ is used, Solidity skips these default checks and assumes that the operation will not result in any issues.
25.	Unchecked can cause arithmetic over and underflow and should be used cautiously.
26.	Require and if condition works in an opposite way (mainly for the relational operators).
27.	View functions don't cost any gas when they're called externally.
28.	View function when called by a non-view function internally cost gas.
29.	Overflows occur when the value to be represented exceeds the range of values representable by a given type. The integer overflow occurs when a number is greater than the maximum value the data type can hold. Uint8 = max[255] + 1 overflow leads to 0, Uint8 = min[0 ] - 1  overflow leads to 255 as it is a –ve overflow.
30.	Underflows occur when the precision a type offers isn't enough to fully represent the result of an operation The integer underflow occurs when a number is smaller than the minimum value the data type can hold. Underflow example is when denom is less than numerator 3/2.
31.	new uint[](3); means initiating an array with length 3. Values are assigned as values[0] = 1;
32.	An array can be build inside a view function with memory pointer which make it retrieving data without any spending any gas.
33.	Code ordering is important in making logic to be strong.
34.	The keyword block.timestamp is constant as storage variable in contract but updated when called within a function.
35.	To pass message in error function string keyword must be declared inside error thisError(string).
