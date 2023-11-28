// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DataConsumerV3 {
    uint256 USDValue = 14e18; // 14 * 10 ** 18; amount in USD
    AggregatorV3Interface[] dataFeed; // arr to add different account to get price feed#

    /**
     * Network: Sepolia
     price feed btc, eth, link, euro and usdc

     ["0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43","0x694AA1769357215DE4FAC081bf1f309aDC325306","0xc59E3633BAAC79493d908e63626716e204A45EdF","0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910","0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E"]
     */
    //   0xA0e1ec8dFCFbF2866Eb0137140E8eC95c3174077 // account address

    mapping (address => uint) public userBalance; //  mapping for updating balance of funder

    function updateBalance(uint tokenValue, uint256 tokenIndex) internal { // function to refund excess amount send
        if (tokenValue > USDValue) { // condition checking if amount sent is greater than defined
            uint exceesAmount =  tokenValue - USDValue; // cache excess amount
            uint256 price = getPrice(tokenIndex); // getting price for specific token
            uint256 refundAmount = (exceesAmount * 1e18) / price; // converting extra amount into 18 decimals to be refund 
            userBalance[msg.sender] -= refundAmount; // substracting refund amount from user balance
            (bool success,) = (msg.sender).call{value:refundAmount}(""); // transferring amount back to user
            require(success, 'reverted txn'); // check for status of amount sent 
        }
        }

        function depositFund(uint tokenIndex) external payable { // function for depositing fund with refund option
        uint tokenPrice = getPriceConversion(tokenIndex, msg.value); // caching value sent by converting into USD
        require(tokenPrice >= USDValue, 'not enough funds'); // checking for minimum amount threshold
        userBalance[msg.sender] += msg.value; // adding value into user balance
        updateBalance(tokenPrice, tokenIndex); // calling refund function
        }
        
        function deposit(uint tokenIndex) external payable { // function to allow user to send fund in this contract
        uint tokenPrice = getPriceConversion(tokenIndex, msg.value);
        require(tokenPrice >= USDValue, 'not enough funds');
        userBalance[msg.sender] += msg.value;
        }

    function dataFeedAddresses(address[] calldata dataFeeds) external { // adding multiple addresss at the same time into data feeds
        for (uint i; i < dataFeeds.length; i++) { // loop to run for all account 
        dataFeed.push(AggregatorV3Interface(dataFeeds[i])); // pushing account into array
        }
        }

        function withdraw() external { // function to withdraw fund out of user
        uint contractBal = address(this).balance; // caching address balance
        dataFeed = new AggregatorV3Interface[](0); // deleting array having feed addresses
        (bool success,) = (msg.sender).call{value:contractBal}(""); // transfer balance and check status
            require(success, 'reverted txn');
        }

    function dataFeedAddress(address dataFeeds) external { // adding one address at a time
        dataFeed.push(AggregatorV3Interface(dataFeeds)); // pushing account into array
        }

    function addressIndexlength(uint feedIndex) external view returns (AggregatorV3Interface) { // checking address at specific index
        return dataFeed[feedIndex]; // return address at given index
        }

 function getPriceConversion(uint tokenIndex, uint tokenAmount) public view returns (uint) { // getting price feed for specific token at given index   
        uint tokenPrice = getPrice(tokenIndex); // caching token price at given index
        uint tokenPriceinUsd = (tokenPrice * tokenAmount) / 1e18; // converting amount sent into USD
        return tokenPriceinUsd; // amount returned
    }

function priceDiffConversion(uint tokenA, uint tokenB) public view returns (uint) { // function to check amount difference between token
        
        uint tokenDiff = getPrice(tokenB) / getPrice(tokenA); // getting amount  from chainlink feed
               
        return tokenDiff; // return amount
    }

    function getPrice(uint feedIndex) public view returns (uint) { // getting price feed for specific token at given index
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed[feedIndex].latestRoundData();
        return uint256(price * 1e10);
    }

      function feedResults(uint feedIndex) public view returns (uint z) { // using switch method to get price feed through assembly
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed[feedIndex].latestRoundData(); // saving price by calling function
        
        assembly {
            switch feedIndex       // condition to switch when specific value is provided 

        case 1 { // return value for token save at index no.1
           z := price
        }

        case 2 { // index no.2
            z := price
        }

         case 3 { // index no.3
            z := price
        }
        
         case 4 {
            z := price
        }

        default { // return value save at index no.0
            z := price
        }
        } } 
        
        }
