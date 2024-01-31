// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundContrct {
    uint256 constant minAmount = 14e18; // same as 2 ether or 2 * 10 ** 18
    address immutable owner; // constructor setting
    uint256 private timeLimit; // state variable

    address[] funders; // index for address of funders
    mapping(address => uint256) funderBalance; // mapping to store funder balance
    mapping(address => bool) funderExists; // mapping to store funder status

    function userAdd(address[] memory userIds) external {
        // method to add multipe users
        for (uint256 i; i < userIds.length; i++) {
            // creating a loop with length of addresses in index
            funders.push(userIds[i]); // pushing addresses into array
        }
    }

    modifier onlyOwner() {
        // modifier to retstrict account access
        require(msg.sender == owner, "onlyOwner Restriction");
        _;
    }

    constructor() payable {
        // constructor   to set immutable params
        owner = msg.sender; // setting deployer as owner;
    }

    // receive() external payable {
    //     // emit Received(msg.sender, msg.value);
    // }

    function addressMultipleHardcode(address[] memory makers) external {
        for (uint256 i; i < makers.length; ++i) {
            funders.push(makers[i]);
        }
    }

    function fundContractRefund() external payable {
        // function to fund contract

        uint256 pricetoken = priceConvert(); // calling function to convert msg.value into USD
        require(pricetoken >= minAmount, "Lower than required Threshold"); // check value is equal or above required amount
        require(funderExists[msg.sender] == false, "Already Funded"); // check sender does not fund previously

        if (pricetoken > minAmount){ // checking if value is sent greater than required

            uint excessAmount = pricetoken - minAmount; // getting access amount

            uint amounttoRefund = ( excessAmount * 1e18 ) / getTokenPrice(); // converting excess amount into ether

            (bool success,) = (msg.sender).call{value:amounttoRefund}(""); // transferring excess amount back to user
            require(success, 'reverted txn'); // checking for return value
        }

        funderExists[msg.sender] = true; // changing status into true
        funderBalance[msg.sender] += msg.value; // incrementing funder balance
        funders.push(msg.sender); // pushing sender into arr inside struct
    }

    function fundWithTimelimit() external payable {
        // method to fund contract with time limit
        require(block.timestamp > timeLimit, "Time Interval Restriction"); // check current time
        require(msg.value >= minAmount, "Lower than required Threshold"); //  check amount sent to contract

        funderExists[msg.sender] = true; // changing status into true
        funderBalance[msg.sender] += msg.value; // incrementing funder balance
        funders.push(msg.sender); // pushing sender into arr inside struct
        timeLimit = block.timestamp + 10 seconds; // creating time limit
    }

    function withDraw() external onlyOwner { // function to withdraw contract balance..restrict to owner
        // payable(msg.sender).transfer(address(this).balance); // transfer method to withdraw

        (bool success,) = msg.sender.call{value: address(this).balance}(""); // making low level call to withdraw
        require(success); // checking for success of txn
    }

    function userBalance(uint256 funderIndex) external view returns (address) {
        // method to initialise struct inside function
        return funders[funderIndex]; // checking user address at given index
    }

    function ownerContract() external view returns (address) {
        return owner; // return contract owner
    }

    function userExist(address user) external view returns (bool) {
        return funderExists[user]; // checking if user has fund the contract
    }

    function userBalance(address user) external view returns (uint256) {
        return funderBalance[user]; // checking user balance as funded
    }

    function getFunders() public view returns (address[] memory) {
        return funders; // returns the whole array
    }

    function getFundersByIndex(uint256 indexNum) public view returns (address) {
        return funders[indexNum]; // returns address at given index
    }

    function contractBalance() external view returns (uint256) {
        uint256 currentBalance = address(this).balance;
        return currentBalance; // returning contract balance
    }

    function priceConvert() public payable returns (uint256) { // method to get ether value in USD
        uint256 converse = (msg.value * getTokenPrice()) / 1e18; // expression to get value in usd
        return converse; // return amount in USD
    }

    function getTokenPrice() public view returns (uint256) {
        // method to get oracle price
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); // eth/usd chainlink feed
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData(); // usd price of eth with 8 decimal
        return uint256(price) * 1e10; // returning with converting into 18 decimals 
    }
}
