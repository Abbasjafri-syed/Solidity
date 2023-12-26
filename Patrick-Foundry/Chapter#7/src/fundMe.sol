// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./priceConvert.sol";

contract fundContrct {
    // library usage for uint256 datatypes
    using PriceConverter for uint256;

    // storage variable are started with 's_' as per convention
    uint256 public s_USDValue = 14e18;

    // contract deployer address set at constructor
    address public immutable s_ownerAccount;

    // mapping to save value against each address
    mapping(address => uint256) public userBalance;

    // contract type for aggregator
    AggregatorV3Interface public s_ApriceFeed;

    constructor(address pFeeder) {
        s_ownerAccount = msg.sender; // owner set suring deployment
        s_ApriceFeed = AggregatorV3Interface(pFeeder); // address of price feed set during deployement
    }
    // deployment through CL
    // forge create contractName --rpc-url $rpc_url  --private-key $pvt_key --constructor-args params // deploy specific contract with constructor
    // forge create fundContrct --rpc-url $test_rpc_url --private-key $test_pvt_key --constructor-args argumen-here // deploy contract on testnet
    // call for read and send for write // call can be used exactly as send for static call
    // cast call/send contractaddress 'tokenPriceFeed(uint)' param1 --rpc-url $test_rpc_url // calling contract method using cast...call for static...send for real txn

    // internal function for refunding
    function updateBalance(uint256 tokenValue, uint256 tokenIndex) internal {
        if (tokenValue > s_USDValue) {
            // checking value if greater than required amount
            uint256 refund = tokenValue - s_USDValue; // subtract amount that exceed limit
            uint256 price = tokenIndex.getPrice(); // get price of token
            uint256 tokenAmountFromUsd = (refund * 1e18) / price; // converting amount to usd
            userBalance[msg.sender] -= tokenAmountFromUsd; // substracting excess amount from user record
            (bool success,) = (msg.sender).call{value: tokenAmountFromUsd}(""); // refunding excess value
            require(success, "reverted txn"); // checking for txn to sucess
        }
    }

    // function to receive fund and refund excess amount
    function depositFund(uint256 tokenIndex) external payable {
        uint256 tokenPrice = tokenIndex.getPriceConversion(msg.value); // converting value into usd
        require(tokenPrice >= s_USDValue, "not enough funds"); // conditon for amount threshold
        userBalance[msg.sender] += msg.value; // adding value to funder record
        updateBalance(tokenPrice, tokenIndex); // calling updateBalance function
    }

    // function for depositing funds
    function deposit(uint256 tokenIndex) external payable {
        uint256 tokenPrice = tokenIndex.getPriceConversion(msg.value); // converting wei value into usd
        require(tokenPrice >= s_USDValue, "not enough funds"); // conditon for amount threshold
        userBalance[msg.sender] += msg.value; // adding value to funder record
    }

    // with contract balance
    function withdraw() external {
        require(s_ownerAccount == msg.sender, 'onlyOwner can send txn'); // only deployer to withdraw
        uint256 contractBal = address(this).balance; // caching contract balance
        (bool success,) = (msg.sender).call{value: contractBal}(""); // transferring through low level call
        require(success, "reverted txn"); // checking for success level
    }

    function getFeedPrice() external view returns (uint256) {
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = s_ApriceFeed.latestRoundData(); // geting price of token
        return uint256(price * 1e10); // making 18 decimal tokens
    }


    // getting address at specific index
    function addressIndexlength(uint256 feedIndex) external pure returns (AggregatorV3Interface) {
        return feedIndex.getFeedAddress(); // return address at given index
    }

    // method to get price of specific token by passing it address
    function tokenAtIndex(uint256 rate, address feedAddress) external view returns (uint256) {
        // return feedIndex.getPrice();
        return rate.getTokenPrice(feedAddress);
    }

    // method to get price of specific token by passing it index
    function tokenPriceFeed(uint256 Index) external view returns (uint256) {
        return Index.getPrice();
    }

    // method to read contract owner
    function contractOwner() external view returns (address) {
        return s_ownerAccount;
    }
}