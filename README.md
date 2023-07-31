# Solidity
Solidity learning basic to advance

# Crypto-Zombies

1.	Fixed length array uint [5] arr; length cannot be increase.
2.	Variable 2 types i.e., value and reference. https://www.geeksforgeeks.org/solidity-types/
3.	Encoding is done using keccak256 which expect single arg in bytes. https://cryptozombies.io/en/lesson/1/chapter/11
4.	Key can be incremented for mapping like  mapping[key]++;
5.	Renounce ownership is setting owner to address(0) which cannot be called anymore. https://cryptozombies.io/en/lesson/3/chapter/2
6.	Better to emit event just before changes takes place. 
7.	If file is imported all contracts will be inherited, if a specific contract is called then it will be inherited then. 
8.	Inheritance rule is followed from origin if a base contract inherits a contract  it can be called to every function that inherits base contract
