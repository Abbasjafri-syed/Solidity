// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {Script} from "lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    uint256 public ANVIL_PVT_KEY = 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a; // anvil local key

    struct NetworkConfig {
        address collateralWBTCfeed;
        address collateralWETHfeed;
        address WBTC;
        address WETH;
        uint256 Depolyer;
    }

    NetworkConfig public ActiveNetworkConfig; // pointer to struct

    constructor() {
        if (block.chainid == 11155111) ActiveNetworkConfig = getSepoliaNetwork(); // if network sepolia user sepolia function
        else ActiveNetworkConfig = getAnvilNetwork(); // if network is local using Anvil function
    }

    function getSepoliaNetwork() internal view returns (NetworkConfig memory SepoliaNetwork) {
        return NetworkConfig(
            0x92A2928f5634BEa89A195e7BeCF0f0FEEDAB885b, // wbtc price feed on Sepolia
            0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, // WETH price feed on Sepolia
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43, // wbtc Token contract on Sepolia
            0x694AA1769357215DE4FAC081bf1f309aDC325306, // WETH token contract on Sepolia
            vm.envUint("PRIVATE_KEY") // Pvt key of Owner
        );
    }

    int256 WBTCPrice = 10000e8; // price for local WBTC
    int256 WETHPrice = 2000e8; // price for local WETH
    uint8 decimals = 8; // Decimals for local tokens

    function getAnvilNetwork() internal returns (NetworkConfig memory AnvilNetwork) {
        MockV3Aggregator WbtcFeed = new MockV3Aggregator(decimals, WBTCPrice); // deploying price feed contract with price decimals and price param
        ERC20Mock Wbtc = new ERC20Mock(address(WbtcFeed)); // depolying ERC20 contract

        MockV3Aggregator WethFeed = new MockV3Aggregator(decimals, WETHPrice);
        ERC20Mock Weth = new ERC20Mock(address(WethFeed));

        if (ActiveNetworkConfig.collateralWBTCfeed != address(0)) {
            return ActiveNetworkConfig; // checking if already deploys return value
        } else { // if already not deployed returns below construct
            return NetworkConfig({
                collateralWBTCfeed: address(WbtcFeed),
                collateralWETHfeed: address(WethFeed),
                WETH: address(Weth),
                WBTC: address(Wbtc),
                Depolyer: ANVIL_PVT_KEY
            });
        }
    }
}
