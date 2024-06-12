// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DynamicNFT} from "../src/Dynam_Nft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DynoNFTDeploy is Script {
    DynamicNFT Test_Nft; // pointer to dynamic NFT Contract
    string cloudy = vm.readFile("./Svg/cloud.svg"); // reading data saved in another file
    string rainny = vm.readFile("./Svg/cloud-rain.svg");
    string sunny = vm.readFile("./Svg/cloud-sun.svg");

    function run() external returns (DynamicNFT) {
        Test_Nft = new DynamicNFT( // passing params
        imageURI(cloudy), imageURI(rainny), imageURI(sunny)); // calling function and converting svg into required formate
        return Test_Nft; // return contract deployed
    }

    function imageURI(string memory SVG) internal pure returns (string memory) {
        string memory Img_BaseUri = "data:image/svg+xml;base64,"; // caching base URI
        string memory Img_URI = string(abi.encodePacked(Img_BaseUri, Base64.encode(bytes(abi.encodePacked(SVG))))); // converting data into base64 and concate with img URI
        return Img_URI; // returning merge data into string type
    }
}
