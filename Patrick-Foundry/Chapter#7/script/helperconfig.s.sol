// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {fundRecv} from "../src/pricing.sol";
import {MockV3Aggregator} from "../src/MockV3Aggregator.sol";

contract HelperFeed is Script {
    // struct is dynamic data type
    struct networkConfig {
        address priceFeed;
    }

    // variable for struct data type
    networkConfig public networkConfigActive;

    // setting address at time fo deployment
    constructor() {
        // condition for checking specific condition
        if (block.chainid == 11155111) {
            networkConfigActive = setUpSepoliaFeed(); // passing address to struct
        } else {
            networkConfigActive = setUpAnvilFeed();
        }
    }

    // saving multiple address in struct
    struct networkConfigMultiple {
        address[] priceFeed;
    }

    // array for struct type
    networkConfigMultiple[] activeNetworkConfig;

    // getting price feed Address saving at specific index
    function getFeedIndex(uint256 configIndex, uint256 priceFeedIndex) external view returns (address) {
        // getting specific index of activeNetworkConfig and saving at data type
        networkConfigMultiple memory config = activeNetworkConfig[configIndex];

        // returning the address saved at given index
        return config.priceFeed[priceFeedIndex];
    }

    // hardcoding address at paticular index
    function setUpSepoliaMulFeed() public returns (networkConfigMultiple memory) {
        // creating struct type for caching
        networkConfigMultiple memory config;

        // initialize a new array in memory
        address[] memory newPriceFeeds = new address[](5);
        newPriceFeeds[0] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
        newPriceFeeds[1] = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        newPriceFeeds[2] = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
        newPriceFeeds[3] = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;
        newPriceFeeds[4] = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;

        // set `priceFeed` member
        // saving  address at particular address of config
        config.priceFeed = newPriceFeeds;

        // push all address saved at config to `activeNetworkConfig`
        activeNetworkConfig.push(config);

        // return all address pushed into array of activeNetworkConfig
        return config;
    }

    // dynamic function to add address inside struct type
    function setFeedMultiple(address[] memory priceFeeds) external {
        // initialize a new struct in memory // dynamic memory type used memory
        networkConfigMultiple memory config;

        // initialize a new array in memory
        address[] memory newPriceFeeds = new address[](priceFeeds.length); // passed as param

        // populate array
        for (uint256 i; i < priceFeeds.length; i++) {
            //  saving each element in the address array
            newPriceFeeds[i] = priceFeeds[i];
        }

        // set `priceFeed` member
        // saving all address at config var
        config.priceFeed = newPriceFeeds;

        // push new config to `networkConfigActive` at following index
        activeNetworkConfig.push(config);
    }

    // function to set price feed address on specific chain
    function setUpSepoliaFeed() public pure returns (networkConfig memory) {
        // saving address using the struct type
        networkConfig memory feedAdd = networkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        // returning the address inside the struct
        return feedAdd;
    }

    // deployement on anvil chain
    function setUpAnvilFeed() public returns (networkConfig memory) {
        // this is simulated txn

        // checking if address is not 0
        if (networkConfigActive.priceFeed != address(0)) {
            return networkConfigActive;
        }

        // this is real txn
        vm.startBroadcast(); // vm is based on script
        /// deploying mock aggregator address
        MockV3Aggregator mockV3 = new MockV3Aggregator(8, 237180680000);
        vm.stopBroadcast();

        // saving price feed address
        networkConfig memory anvilConfig = networkConfig({priceFeed: address(mockV3)});

        // returning address inside struct type
        return anvilConfig;
    }
}
