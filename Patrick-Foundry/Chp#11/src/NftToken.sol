// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract ERCNFT is ERC721, Ownable {
    uint256 public ID_Count; // id count for every NFT
    mapping(address NFT_Owner => uint256 Nft_Owned) private Nft_Count; // mapping to know Nft owned by an address
    mapping(uint256 NFT_ID => address NFT_Owner) private Nft_Owner; // mapping to know Nft Owner by an address

    error NFTAmountLess(uint256 Amount); // custom error to logged with reverting amount
    error TransferFailed(uint256 transferred_Amount);

    constructor() ERC721("MyNFT", "Manto") Ownable(msg.sender) {
        mint_Nft(); // calling mint function to have 1st nft to owner
    }

    receive() external payable {
        if (msg.value < 0.01 ether) {
            // checking if value is less than threshold revert
            revert NFTAmountLess(msg.value); // revrting with custom error
        } else if (msg.value > 0.01 ether) {
            // if value is more than required call refund function
            refund(msg.value);
        } else {
            mint_Nft(); // calling function to mint nft
        }
    }

    function mint_Nft() public {
        Nft_Count[msg.sender]++; // incrementing number of NFT owned
        Nft_Owner[ID_Count] = msg.sender; // NFT owned by holder
        _mint(msg.sender, ID_Count); // minting first NFT
        ID_Count++; // increment the count
    }

    function multiple_mint() public payable {
        require(msg.value >= 0.01 ether, "At least 0.01 eth required"); // defining threshold
        uint256 NFT_Price = msg.value / 0.01 ether; // define price 100 nft per ether
        for (uint256 i; i < NFT_Price; ++i) {
            // running loop for price
            mint_Nft(); // minting NFt till condition is true
        }
    }

    function refund(uint256 Token_Amount) internal {
        uint256 amountRefund = Token_Amount - 0.01 ether; // caching amount if excess
        (bool success,) = msg.sender.call{value: amountRefund}(""); // transferring back additional amount
        if (!success) {
            revert TransferFailed(Token_Amount); // reverting with value
        }
        mint_Nft(); // calling mint function
    }

    function get_NFTOwner(uint256 NFT_TokenID) external view returns (address) {
        return Nft_Owner[NFT_TokenID]; // returning Owner of NFT
    }

    function get_Total_NFTOwned(address NFT_Owner) external view returns (uint256) {
        return Nft_Count[NFT_Owner]; // returning total number of NFT Owned by an address
    }

    // function to get URI by passing its ID
    function Nft_URI(uint256 token_Id) external pure returns (string memory) {
        string memory tokenIdStr = Strings.toString(token_Id); // method to convert integer into string
        string memory concate = string( // casting value with encoded data
        abi.encodePacked("ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/", tokenIdStr, ".png"));
        return concate;
    }

    // function to get URI by passing its bytes ID i Bytes
    function Nft_BytesURI(bytes memory token_Id) external pure returns (string memory) {
        uint256 tokenIdUint = abi.decode(token_Id, (uint256)); // decoding bytes data into integer type
        string memory tokenIdStr = Strings.toString(tokenIdUint); // converting integer to string
        string memory concate = string( // casting value with encoded data
        abi.encodePacked("ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/", tokenIdStr, ".png"));
        return concate;
    }
}
