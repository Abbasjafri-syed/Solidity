// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {NFTDeployDyno as makerDyno} from "../script/dynoNft_Deploy.s.sol";
import {DynamicNFT} from "../src/Dynam_Nft.sol";

import {console, Test} from "forge-std/Test.sol";

contract NFT721Test is Test {
    address funder = makeAddr("funder"); // random user creation
    makerDyno Nft_Deploy; // pointer to deployment script
    DynamicNFT dyno_Nft; // pointer to contract testing

    error Weather_AlreadyExist(uint256 value); // error of price

    function setUp() public {
        Nft_Deploy = new makerDyno(); // deploying through script
        dyno_Nft = Nft_Deploy.run();
    }

    // forge t --mt test_NFTinit -vvv
    function test_NFTinit() public {
        hoax(funder, 10 ether); // prank and funding user
        dyno_Nft.minter_Nft{value: 0.108 ether}(); // calling function with sending funds

        uint256 maker = dyno_Nft.get_NftCount(funder); // counting nft owned by user
        // console.log("Owned NFT balance: ", maker);
        vm.assertEq(maker, 10, "Value not match"); //asserting total owned

        address Owner = dyno_Nft.get_NftOwner(2);
        console.log("Owner:", Owner);
        console.log("funder:", funder);
    }

    // forge t --mt test_fib -vvv
    function test_fib() external view {
        dyno_Nft.fibonacci(10);
    }

    // forge t --mt test_getW -vvv
    function test_getW() internal {
        test_NFTinit(); // calling init function
        // uint countNft = uint256(dyno_Nft.get_IDNft() - 1);

        uint256[] memory nftsArray = dyno_Nft.get_NFTsByWeather(dyno_Nft.get_IDNft(), 0); // getting all ids
        for (uint256 i = 0; i < nftsArray.length; i++) {
            console.log("nftsArray no:", nftsArray[i]);
        }
    }

    // forge t --mt test_setWeth -vvv
    function test_setWeth() external {
        test_getW(); // calling test_getW function

        vm.prank(funder); // start call with funder
        dyno_Nft.allocateWeather{value: 0.008 ether}(7, 1); // call functtion to change wetaher

        uint256[] memory nftsArray = dyno_Nft.get_NFTsByWeather(dyno_Nft.get_IDNft(), 1); // getting all ids with id

        for (uint256 i = 0; i < nftsArray.length; i++) {
            console.log("nftsArray no:", nftsArray[i]); // running loop to print all nfts with specific weather
        }
    }

    // forge t --mt test_weatherSet -vvv
    function test_weatherSet() external {
        test_NFTinit(); // calling init function

        vm.startPrank(funder); // starting call with user
        string memory tokenURI = dyno_Nft.get_tokenURI(9); // caching token uri
        console.log("tokenURI:\n", tokenURI); // logging token URI

        uint256 Weath = dyno_Nft.get_NftWeather(9); // getting uri of requried nft
        vm.assertEq(Weath, uint256(DynamicNFT.Weather.sunny)); // asserting value of nft equal to sunny

        vm.expectRevert(abi.encodeWithSelector(DynamicNFT.Weather_AlreadyExist.selector, 2)); // expecting revert as weather already exist
        dyno_Nft.set_Weather{value: 0.001 ether}(9, 2); // fail txn

        dyno_Nft.set_Weather{value: 0.001 ether}(9, 1); // calling function to change value
        Weath = dyno_Nft.get_NftWeather(9); // getting uri of requried nft
        console.log("NFT Weather", Weath); // logging token URI

        vm.assertEq(Weath, uint256(DynamicNFT.Weather.rainny)); // asserting value of nft equal to sunny

        tokenURI = dyno_Nft.get_tokenURI(9); // caching token uri
        console.log("tokenURI:\n", tokenURI); // logging token URI
    }

    // forge t --mt test_flipper -vvv
    function test_flipper() external {
        test_NFTinit(); // calling init function
        dyno_Nft.get_Weath(9); // getting
    }

    // forge t --mt test_Nftmint -vvv
    function test_Nftmint() external {
        test_NFTinit(); // calling init function

        uint256 ID_Nft = dyno_Nft.get_IDNft();
        console.log("NFT IDs: ", ID_Nft);
    }

    // forge t --mt test_DUri -vvv
    function test_DUri() external {
        test_NFTinit(); // calling init function

        string memory later = dyno_Nft.default_tokenUri(9); // getting uri of requried nft
        console.log("NFT URI:\n", later); // logging
    }
}
