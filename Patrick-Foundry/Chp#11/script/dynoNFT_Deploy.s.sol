// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DynamicNFT} from "../src/Dynam_Nft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract NFTDeployDyno is Script {
    DynamicNFT Test_Nft; // pointer to dynamic NFT Contract
    string cloudy = vm.readFile("./Svg/cloud.svg"); // reading data saved in another file
    string rainny = vm.readFile("./Svg/cloud-rain.svg");
    string sunny = vm.readFile("./Svg/cloud-sun.svg");

    function run() external returns (DynamicNFT) {
        vm.startBroadcast();
        Test_Nft = new DynamicNFT( // passing params
        imageURI(cloudy), imageURI(rainny), imageURI(sunny)); // calling function and converting svg into required formate
        vm.stopBroadcast();
        return Test_Nft; // return contract deployed
    }

    function imageURI(string memory SVG) internal pure returns (string memory) {
        string memory Img_BaseUri = "data:image/svg+xml;base64,"; // caching base URI
        string memory Img_URI = string(abi.encodePacked(Img_BaseUri, Base64.encode(bytes(abi.encodePacked(SVG))))); // converting data into base64 and concate with img URI
        return Img_URI; // returning merge data into string type
    }
}

// Anvil deployment

// forge script script/dynoNFT_Deploy.s.sol:NFTDeployDyno --rpc-url $rpc_url --private-key $pvt_key --broadcast

// 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141 // contract address

// cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 'minter_Nft()' --value 0.1ether --private-key $pvt_key --rpc-url $rpc_url

// cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 'get_NftCount(address)' 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key $pvt_key --rpc-url $rpc_url

// cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 'get_NftOwner(uint)' 10 --private-key $pvt_key --rpc-url $rpc_url

//
