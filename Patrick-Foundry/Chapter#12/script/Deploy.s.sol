// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";
import {DcentralStable} from "src/ERC20Main.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract deployScript is Script {
    DcentralStable DSC;
    DSCEngine engine;
    HelperConfig config;

    address[] public tokens;
    address[] public priceFeeds;

    function run() external returns (DcentralStable, DSCEngine, HelperConfig) {
        config = new HelperConfig(); // deploying config contract

        (address collateralWBTCfeed, address collateralWETHfeed, address WBTC, address WETH, uint256 Depolyerkey) =
            config.ActiveNetworkConfig(); // getting values from active network struct
        tokens = [WBTC, WETH]; // adding address to array
        priceFeeds = [collateralWBTCfeed, collateralWETHfeed];

        vm.startBroadcast(Depolyerkey); // broadcasting
        DSC = new DcentralStable(); //deploying contract
        engine = new DSCEngine(tokens, priceFeeds, address(DSC));
        DSC.transferOwnership(address(engine)); // transferring ownership
        vm.stopBroadcast();
        return (DSC, engine, config);
    }
}
