// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {ERCNFT} from "../src/NftToken.sol";
import {NFT721Deploy} from "../script/Nft_Deploy.s.sol";
import {RecentNft} from "../script/interactions.s.sol";
import {console, Test} from "forge-std/Test.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT721Test is Test {
    ERCNFT NFT_ERC; // pointer towards NFT contract
    NFT721Deploy NFT_Deployer; // pointer for Script contract
    RecentNft recent; // latest deployed contract

    address funder = makeAddr("funder");

    // main function for test
    function setUp() external {
        NFT_Deployer = new NFT721Deploy(); // deploying script contract
        NFT_ERC = NFT_Deployer.run(); // caching address retruned from deployer
        recent = new RecentNft(); // caching RecentNft address
    }

    // forge t --mt test_amount -vv
    function test_amount() external {
        hoax(funder, 10 ether);
        NFT_ERC.multiple_mint{value: 1 ether}();
        uint256 Nft_Count = NFT_ERC.get_Total_NFTOwned(funder);
        console.log("Owner Nft_Count:", Nft_Count);
    }

    // forge t --mt test_concat -vv
    function test_concat() external {
        string memory maker = string.concat("maker is:", "funder", "causing call");
        console.log(maker);
    }

    // forge t --mt test_fuzzbit -vv
    function test_fuzzbit(address a, address b) external {
        // address owner = makeAddr("owner");
        // address account = makeAddr("account");
        uint256 bitMask = 1 << (uint160(a) ^ uint160(b));
        if (bitMask == 0) {
        bitMask = 1 << 1;
    }
        console.log("bitMask:", bitMask);
    }

    // forge t --mt test_recentHolder -f $rpc_url -vv
    function test_recentHolder() external {
        console.log("Owner Address:", NFT_ERC.owner());
        console.log("RecentNft Address:", address(recent));
    }

    // forge t --mt test_latestInteraction -f $rpc_url -vv
    function test_latestInteraction() external {
        recent.latest_Deployed(payable(NFT_ERC)); // calling latest deployed() with param address

        console.log("NFT_Count", NFT_ERC.ID_Count()); // current nft mint amount ..is -1
        address Nft_id = NFT_ERC.get_NFTOwner(1); // caching owner of nft 1
        console.log("Nft_Owner", Nft_id);
        assertEq(Nft_id, msg.sender); // validating owner of newly minted nft with devops
    }

    // getting infor for all contracts related
    function test_ContractInfo() external view {
        console.log("NFT address:", address(NFT_ERC));
        console.log("Deployer address:", address(NFT_Deployer));
        console.log("Owner Address:", NFT_ERC.owner());
        console.log("Default Sender Address:", msg.sender);
    } // forge t --mt test_ContractInfo -vv

    function test_NftCount() external view {
        uint256 Nft_Owned = NFT_ERC.get_Total_NFTOwned(NFT_ERC.owner()); // number of nft Owned
        // console.log(Nft_Owned);
        assertEq(Nft_Owned, 1); // asserting NFT count
    } // forge t --mt test_NftOwner -vv

    function test_NftOwner() external view {
        address Nft_Owner = NFT_ERC.get_NFTOwner(0); // number of nft Owned
        // console.log(Nft_Owned);
        assertEq(Nft_Owner, NFT_ERC.owner()); // asserting NFT count
    } // forge t --mt test_NftOwner -vv

    function test_Fund2Mint() external {
        hoax(funder, 10 ether); // funding and pranking with user
        (bool success,) = address(NFT_ERC).call{value: 1 ether}(""); //low level call for funding
        require(success == true, "Amount Transfer Failed");
        uint256 Nft_Owned = NFT_ERC.get_Total_NFTOwned(funder); // number of nft Owned
        address Nft_Owner = NFT_ERC.get_NFTOwner(1); // number of nft Owned

        assertEq(Nft_Owned, 1); // asserting NFT count
        assertEq(Nft_Owner, funder); // asserting NFT count
        console.log("Funder balance: %e", funder.balance);
        assertEq(funder.balance, 9.99 ether); // asserting NFT count
    } // forge t --mt test_Fund2Mint -vv

    receive() external payable {}

    function test_nonReceiveableSenderThis() external {
        hoax(address(this), 10 ether); // funding and pranking with user

        vm.expectRevert(abi.encodeWithSelector(ERCNFT.TransferFailed.selector, 1 ether)); // if this test is non -recievable revrting with custom error by passing param
        // vm.expectRevert(); // same as above without param
        (bool success,) = address(NFT_ERC).call{value: 1 ether}(""); //low level call for funding
        require(success == true, "Amount Transfer Failed");

        assertEq(address(this).balance, 10 ether); // validating test contract balance
    } // forge t --mt test_nonReceiveableSender -vv

    function test_ReceiveableSenderThis() external {
        hoax(address(this), 10 ether); // funding and pranking with user

        (bool success,) = address(NFT_ERC).call{value: 1 ether}(""); //low level call for funding
        require(success == true, "Amount Transfer Failed");
        uint256 Nft_Owned = NFT_ERC.get_Total_NFTOwned(address(this)); // number of nft Owned

        assertEq(address(NFT_ERC).balance, 0.01 ether); // validating balance of NFT_ERC
        assertEq(address(this).balance, 9.99 ether); // validating balance of address(this)
        assertEq(Nft_Owned, 1); // asserting NFT count
    } // forge t --mt test_ReceiveableSenderThis -vv

    // method to attach integer with string
    function test_stringConcatBytes() external view {
        uint256 token_Id = 522;
        bytes memory tokenIdUint = abi.encodePacked(token_Id); // converting uint into bytes
        string memory Nft_Bytes = NFT_ERC.Nft_BytesURI((tokenIdUint)); // calling function and caching return value
        console.logBytes(tokenIdUint); // method to log bytes data type
        console.log("NFT Storgae location:", Nft_Bytes);
    } // forge t --mt test_stringConcatBytes -vv

    function test_concatString() external view {
        string memory Nft_Bytes = NFT_ERC.Nft_URI((123)); // calling function and caching return value
        console.log("NFT IPFS location:", Nft_Bytes);
    } // forge t --mt test_concatString -vv

    function test_convertString() external view {
        string memory tokenIdStr = Strings.toString(423); // method to convert integer into string
        string memory concate = string( // casting to string for concatenation
        abi.encodePacked("ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/", tokenIdStr, ".png"));
        console.log("NFT IPFS location:", concate);
    } // forge t --mt test_convertString -vv
}
