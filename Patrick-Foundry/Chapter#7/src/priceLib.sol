// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * Network: Sepolia
     *  price feed btc, eth, link, euro and usdc
     *   AggregatorV3Interface[] dataFeed = [
     *     "0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43",
     *     "0x694AA1769357215DE4FAC081bf1f309aDC325306",
     *     "0xc59E3633BAAC79493d908e63626716e204A45EdF",
     *     "0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910",
     *     "0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E"
     * ];
     */

    function getFeedAddress(uint256 feedIndex) internal pure returns (AggregatorV3Interface) {
        AggregatorV3Interface[] memory dataFeed = new AggregatorV3Interface[](5); // arr to add different account to get price feed
        dataFeed[0] = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        dataFeed[1] = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        dataFeed[2] = AggregatorV3Interface(0xc59E3633BAAC79493d908e63626716e204A45EdF);
        dataFeed[3] = AggregatorV3Interface(0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
        dataFeed[4] = AggregatorV3Interface(0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E);
        return dataFeed[feedIndex];
    }

    function getTokenPrice(uint256 indexer, address feedAddress) internal view returns (uint256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(feedAddress);
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        indexer = 1e10;
        return uint256(price * int256(indexer));
    }

    function getPriceConversion(uint256 tokenIndex, uint256 tokenAmount) internal view returns (uint256) {
        uint256 tokenPrice = getPrice(tokenIndex);
        uint256 tokenPriceinUsd = (tokenPrice * tokenAmount) / 1e18;
        return tokenPriceinUsd;
    }

    function getPrice(uint256 feedIndex) internal view returns (uint256) {
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = getFeedAddress(feedIndex).latestRoundData();
        return uint256(price * 1e10);
    }
}
