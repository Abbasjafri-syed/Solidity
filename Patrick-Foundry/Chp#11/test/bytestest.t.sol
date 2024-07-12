// SPDX-License-Identifier: None

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ERCNFT} from "../src/NftToken.sol";
import {dataString} from "../src/returnData.sol";

contract bytesTest is Test {
    string str_Maker = "StringTest";
    uint256 jared = 123; // casting numer into string

    ERCNFT NFT_deployer;

    function setUp() external {
        NFT_deployer = new ERCNFT(); // deploying contract and caching
    }

    // forge t --mt test_signcall -vvv
    function test_signcall() external {
        hoax(address(1), 1 ether); // pranking and funding user
        (bool success,) = address(NFT_deployer).call{value: 0.1 ether}(abi.encodeWithSignature("multiple_mint()", "")); // low level call through function signature
        // console.log("Success:", success); // logging bool
        assertEq(success, true, "return value False"); // validating succesfull transfer

        uint256 NftCount = NFT_deployer.get_Total_NFTOwned(address(1)); // caching nft owned by user
        // console.log("NftCount:", NftCount);
        assertEq(NftCount, 10, "NFT not owned"); // validating NFt holds by user
    }

    // forge t --mt test_bytesLength -vvv
    function test_bytesLength() external view {
        bytes memory cloudy = abi.encode(NFT_deployer.return_Data()); // reading data saved in another file and convertng

        // console.logBytes(cloudy); // logging data
        uint256 datalength = cloudy.length; // getting length of bytes data
        console.log("datalength", datalength);

        bytes memory data = abi.encode(("String"));
        console.log("data", data.length);
        // console.logBytes(data);
    }

    function selectorgen(string memory func) public pure returns (bytes4) {
        bytes4 selector = bytes4(keccak256(bytes(func))); // method to generate function selector from signature
        return selector;
    }

    // forge t --mt test_functionTransfer -vvv
    function test_functionTransfer() external {
        vm.prank(address(1));
        (bool success, bytes memory maker) =
            address(NFT_deployer).call(abi.encodeWithSelector(selectorgen("mint_Nft()"), ""));
        // console.log("Success:", success);
        assertEq(success, true, "return value False"); // validating succesfull transfer

        uint256 length = maker.length;
        console.logBytes(maker);
        console.log("bytes length:", length);

        uint256 NftCount = NFT_deployer.get_Total_NFTOwned(address(1));
        // console.log("NftCount:", NftCount);
        assertEq(NftCount, 1, "NFT not owned"); // validating NFt holds by user
    }

    // forge t --mt test_bytes -vvv
    function test_bytes() external view {
        bytes memory encoder = abi.encode(str_Maker, jared); // encode method
        console.log("Encode:");
        console.logBytes(encoder); // logging encode

        bytes memory encodePacker = abi.encodePacked(str_Maker, jared); // encode Packed method
        console.log("Packed:");
        console.logBytes(encodePacker); // logging encode Packed
    }

    // forge t --mt test_multiencode -vvv
    function test_multiencode() external view {
        bytes memory encoder = abi.encode(str_Maker, jared); // multi encode method
        (string memory maker, uint256 decker) = abi.decode(encoder, (string, uint256)); // multi encode require mulitple type define for decoding
        console.log("maker:", maker, "decker:", decker);
    }

    // forge t --mt test_multiPacked -vvv
    function test_multiPacked() external view {
        bytes memory encoder = abi.encodePacked(str_Maker, jared); // multi encode method
        string memory maker = string(encoder); // multi packed generate result which is concat
        console.log(maker);
    }

    function transferFrom(address from, address to, uint256 value) external {}

    // forge t --mt test_functionSelector -vvv
    function test_functionSelector() external view {
        bytes4 selector = bytes4(keccak256("transferFrom(address,address,uint256)")); // method to generate function selector from signature
        bytes4 select = this.transferFrom.selector; // method to generate selector function within contract
        console.log("Function Selector:");
        console.logBytes4(selector); // log method for bytes
        console.logBytes4(select);
    }
}
