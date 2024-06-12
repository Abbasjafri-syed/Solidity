// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract DynamicNFT is ERC721, Ownable {
    uint256 private token_ID; // number of NFT minted - 1
    string Svg_Cloudy; // dynamic nft 1
    string public Svg_Cloudy_Rain; // dynamic nft 2
    string Svg_Cloudy_Sun; // dynamic nft 3
    uint256 private amounts = 0.01 ether; // amount for NFT
    uint256 NFT_Price; // price of nft
    uint256 private ChangePrice = 0.001 ether; // price to change weather

    error Weather_AlreadyExist(uint256 value); // error of price

    enum Weather { // enum for weather
        cloudy,
        rainny,
        sunny
    }

    mapping(address NFT_Owner => uint256 Nft_Owned) private Nft_Count; // mapping to know Nft owned by an address
    mapping(uint256 NFT_ID => address NFT_Owner) private Nft_Owner; // mapping to know Nft Owner by an address
    mapping(uint256 NFT_ID => Weather) private Nft_Weather; // Weather mapping of Nft Owner

    constructor(string memory cloudy, string memory rainny, string memory sunny)
        Ownable()
        ERC721("Weather_Nfts", "Dyno_W")
    {
        Svg_Cloudy = cloudy;
        Svg_Cloudy_Rain = rainny;
        Svg_Cloudy_Sun = sunny;
    }

    modifier pay_Amount() {
        require(msg.value >= amounts, "amount less than threshold");
        uint256 amount_refunded; // variable for amount to be refunded
        if (msg.value > amounts) {
            NFT_Price = msg.value / amounts; // define price 100 nft per ether
            uint256 Nft_minted_amount = NFT_Price * amounts; // total amount of nft mInted
            amount_refunded = msg.value - Nft_minted_amount; // caching amohnt to be refunded
        }
        _;
        if (amount_refunded > 0) {
            // if amount is greater than zero carry out transfer
            (bool success,) = msg.sender.call{value: amount_refunded}(""); // making transfer through low level call
            require(success, "transfer failed"); // checking retrun value
        }
    }

    function minter_Nft() external payable pay_Amount {
        for (uint256 i; i < NFT_Price; ++i) {
            Nft_Count[msg.sender]++; // incrementing number of NFT owned
            Nft_Owner[token_ID] = msg.sender; // NFT owned by holder
            Nft_Weather[token_ID] = Weather.sunny; // default weather is sunny
            _safeMint(msg.sender, token_ID); // mint nft at current Id
            ++token_ID; // increment
        }
    }

    function refund_FlipAmount(uint256 amount) internal {
        uint256 excessAmount = amount - ChangePrice; // caching price that has to be refunded
        (bool success,) = msg.sender.call{value: excessAmount}(""); // making low level call to return excess funds
        require(success, "Transfer failed"); // validating return value of low level call
    }

    function set_Weather(uint256 tokenId, uint256 weather_Flip) external payable {
        require(_isApprovedOrOwner(msg.sender, tokenId)); // check if send is owner or spender
        require(msg.value >= ChangePrice, "Amount is less than Threshold");
        if (msg.value > ChangePrice) {
            // checking if excess funds are send
            refund_FlipAmount(msg.value); //  if amount is excess refund function is called
        }
        if (weather_Flip == uint256(Nft_Weather[tokenId])) {
            // checking if weather already exists
            revert Weather_AlreadyExist(weather_Flip); // reverting if weather already existed
        }

        Nft_Weather[tokenId] = Weather(weather_Flip); // passing value to token id 
    }

    function get_tokenURI(uint256 tkn_Id) external view returns (string memory tkn_URI) {
        require(Nft_Owner[tkn_Id] != address(0), "NFT does not Exist"); // sanity check to ensure nft exist
        string memory baseUri = "data:application/json;base64,"; // caching base URI
        string memory active_Img; // defining active of NFT

        active_Img = Nft_Weather[tkn_Id] == Weather.sunny // caching active svg based on weather enum
            ? Svg_Cloudy_Sun
            : Nft_Weather[tkn_Id] == Weather.cloudy ? Svg_Cloudy : Svg_Cloudy_Rain;

        tkn_URI = string( // changing encode data to string
            abi.encodePacked( // encoding all types of data
                baseUri,
                (
                    Base64.encode( // encoding data into base 64
                        bytes(
                            abi.encodePacked( // encoding all types of data
                                '{ "Name":',
                                name(),
                                ' "Description": "Nft representing changing weather Pattern", "Token_Id": ',
                                Strings.toString(tkn_Id), // changing token id to string
                                '\n "ImageURI": \n',
                                active_Img, // getting active SVG
                                "\n}"
                            )
                        )
                    )
                )
            )
        );
        return tkn_URI; // returning token URI
    }

    function getImageUri() internal pure returns (string memory) {
        // harddcoded URI
        string memory URI_image =
            "data:image/svg+xml;base64,PCEtLSA8c3ZnIHdpZHRoPSI0MDBweCIgaGVpZ2h0PSI0MDBweCIgdmlld0JveD0iMCAwIDQwIDQwIiBmaWxsPSJsaWdodGJsdWUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+DQo8cGF0aCBkPSJNNCAxNC43NTE5QzMuMzcwMzcgMTMuODc2OCAzIDEyLjgwNTkgMyAxMS42NDkzQzMgOS4yMDAwOCA0LjggNi45Mzc1IDcuNSA2LjVDOC4zNDY5NCA0LjQ4NjM3IDEwLjM1MTQgMyAxMi42ODkzIDNDMTUuNjg0IDMgMTguMTMxNyA1LjMyMjUxIDE4LjMgOC4yNUMxOS44ODkzIDguOTQ0ODggMjEgMTAuNjUwMyAyMSAxMi40OTY5QzIxIDEzLjU2OTMgMjAuNjI1NCAxNC41NTQxIDIwIDE1LjMyNzVNMTIuNSAxMi45OTk1TDEwLjUgMjEuMDAwOE04LjUgMTEuOTk5NUw2LjUgMjAuMDAwOE0xNi41IDEyTDE0LjUgMjAuMDAxMyIgc3Ryb2tlPSIjMDAwMDAwIiBzdHJva2Utd2lkdGg9IjEuNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+DQo8L3N2Zz4gLS0+DQoNCjxzdmcgd2lkdGg9IjQwMHB4IiBoZWlnaHQ9IjQwMHB4IiB2aWV3Qm94PSIwIDAgNDAgNDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+DQogICAgPHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0ibGlnaHRwaW5rIi8+DQogICAgPHBhdGggZD0iTTQgMTQuNzUxOUMzLjM3MDM3IDEzLjg3NjggMyAxMi44MDU5IDMgMTEuNjQ5M0MzIDkuMjAwMDggNC44IDYuOTM3NSA3LjUgNi41QzguMzQ2OTQgNC40ODYzNyAxMC4zNTE0IDMgMTIuNjg5MyAzQzE1LjY4NCAzIDE4LjEzMTcgNS4zMjI1MSAxOC4zIDguMjVDMTkuODg5MyA4Ljk0NDg4IDIxIDEwLjY1MDMgMjEgMTIuNDk2OUMyMSAxMy41NjkzIDIwLjYyNTQgMTQuNTU0MSAyMCAxNS4zMjc1TTEyLjUgMTIuOTk5NUwxMC41IDIxLjAwMDhNOC41IDExLjk5OTVMNi41IDIwLjAwMDhNMTYuNSAxMkwxNC41IDIwLjAwMTMiIHN0cm9rZT0iIzgwMDA4MCIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPg0KPC9zdmc+";
        return URI_image;
    }

    function default_tokenUri(uint256 tokenId) external view returns (string memory nft_URI) {
        require(Nft_Owner[tokenId] != address(0), "NFT does not exists"); // checking nft is minted
        string memory token_BaseUri = "data:application/json;base64,"; // caching base URI

        nft_URI = string( // encoding all data to generate metadata string value
            abi.encodePacked(
                token_BaseUri,
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"Name": ',
                            name(),
                            ', "Description":, "Nft representing changing weather Pattern", "Token_Id": ',
                            Strings.toString(tokenId),
                            ', \n "Image Uri": \n',
                            Svg_Cloudy_Sun,
                            "\n}"
                        )
                    )
                )
            )
        );
        return nft_URI; // returning URI of Token
    }

    function get_NftCount(address Owner) external view returns (uint256) {
        return Nft_Count[Owner]; // nft owned by an address
    }

    function get_Weath(uint256 nftId) external view returns (Weather) {
        return Nft_Weather[nftId]; // nft owned by an address
    }

    function get_NftWeather(uint256 nftId) external view returns (uint256) {
        return uint256(Nft_Weather[nftId]); // weather of nft
    }

    function get_NftOwner(uint256 nftId) external view returns (address) {
        return Nft_Owner[nftId]; // nft owned by an address
    }

    function get_IDNft() external view returns (uint256) {
        return token_ID; // total number of id minted -1
    }
}
