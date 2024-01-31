// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {console2, Test} from "forge-std/Test.sol";
import {configtest} from "../script/netconfig.s.sol";

contract testConfig is Test { 
    address caller = makeAddr("caller"); // creating a random address
    configtest config; // contract datat type

    function setUp() public returns (configtest) { // required function in test
        config = new configtest(); // deploying new contract
        return config; // return contract
    }

    function test_Sepolia() public { // checking address for seplia
        address sep = config.SepoliaFeed();
        assertEq(sep, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        console2.log(sep);
    }

    function test_Anvil() public { // checking address for anvil
        address anvl = config.AnvilFeed();
        assertEq(anvl, 0x104fBc016F4bb334D775a19E8A6510109AC63E00);
        console2.log(anvl);
    }

    function test_feedAnvil() public { // checking address for anvil network
        address anvilfeed = config.addressFeed(); 
        console2.log(anvilfeed);
        assertEq(anvilfeed, 0x104fBc016F4bb334D775a19E8A6510109AC63E00);
    }

    function test_feedSepolia() public { // checking address for seplia network
        address sepoliaFeed = config.addressFeed();
        console2.log(sepoliaFeed);
        assertEq(sepoliaFeed, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function test_sepToken() public { // test for seploa token price
        uint256 sepoliaPrice = config.getTokenPrice();
        console2.log(sepoliaPrice);
        assertEq(sepoliaPrice, 2356997389720000000000);
    }

    function test_anvlToken() public {// test for anvil token price
        uint256 anvlPrice = config.getTokenPrice();
        console2.log(anvlPrice);
        assertEq(anvlPrice, 235012345678e10);
    }

    function test_priceUSD() public { // test to check ether price in USD
        hoax(caller, 10 ether);
        uint256 priceUSD = config.priceConvert{value: 0.005 ether}();
        console2.log(priceUSD);
    }


    // forge test --mc testConfig
    // forge test --mt test_Anvil -vvv
    // forge test -f $test_rpc_url --mt test_priceUSD -vvv
}
