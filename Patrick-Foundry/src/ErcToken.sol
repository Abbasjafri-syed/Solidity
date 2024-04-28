// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERCtoken is ERC20, Ownable {
    uint256 private immutable Max_Supply; //  max token supply
    uint256 internal immutable Start_Time; // start time for minting

    uint256 private current_Minted; // caching Amount Total Minted till Current Time

    error Over_Supply(uint256 token_Supply); // error for Supply
    error Over_Time(uint256 time_Limit); // error for Time

    constructor(uint256 Init_Value) ERC20("Ethereum", "Ether") Ownable(msg.sender) {
        Max_Supply = 2100 ether; //  same as 21 * 10 ** 10 or 210 billion
        Start_Time = block.timestamp; // setting start time
        require(Init_Value <= Max_Supply, "Exceed Token Maximum Limit"); // checking limit to avoid minting more than max. limit
        current_Minted = Init_Value; // caching minted amount
        _mint(msg.sender, Init_Value); // minting tokens
    }

    function getMaximumSupply() external view returns (uint256) {
        // function to check maxmium supply
        return Max_Supply;
    }

    function donateETH() external payable {}

    // add timelock to limit minting till specific time

    receive() external payable {
        // when a user send ether mint them tokens as per condition
        mint_Tokens(msg.sender);
    }

    function maker() public payable {
        // add timelock to limit minting till specific time
        uint256 CoinAmount;
        if (current_Minted <= 710 ether) {
            // till supply is 710 coins
            CoinAmount = (msg.value / 2e15) * 1 ether; // 500 coins for 1 ether
            current_Minted += CoinAmount; // current mint amount
            _mint(msg.sender, CoinAmount); // minting tokens
        } else if (current_Minted <= 1500 ether) {
            // supply till 1500 coins
            CoinAmount = (msg.value / 4e15) * 1 ether; // 250 coins for 1 ether
            current_Minted += CoinAmount; // current mint amount
            _mint(msg.sender, CoinAmount); // minting tokens
        } else {
            // 100 coins for 1 ether
            if (
                current_Minted < Max_Supply // checking supply to not exceed max limit
            ) {
                // checking if supply is within limit
                CoinAmount = (msg.value / 1e16) * 1 ether; // 100 coins / 1 Eth
                current_Minted += CoinAmount; // current mint amount
                _mint(msg.sender, CoinAmount); // minting tokens
            }
        }
    }

    function mint_Tokens(address _to) public payable returns (address) {
        uint256 CoinAmount;
        uint256 first_Sale = Start_Time + 1 days;
        uint256 second_Sale = first_Sale + 1 days;
        uint256 general_Sale = second_Sale + 10 seconds;

        if (block.timestamp <= first_Sale) {
            // if time limit exist but supply exceed
            if (current_Minted > 710 ether) {
                // if supply exceed supply limit
                revert Over_Supply(current_Minted); // reverting with custome error
            } else {
                // if (totalSupply() <= 710 ether) {
                // till supply is 710 coins
                CoinAmount = (msg.value / 2e15) * 1 ether; // 500 coins for 1 ether
                current_Minted += CoinAmount; // current mint amount
                _mint(_to, CoinAmount); // minting tokens
                    // }
            }
        } else if (block.timestamp > first_Sale && block.timestamp <= second_Sale) {
            // if time limit exist but supply exceed
            if (current_Minted >= 1500 ether) {
                // if supply exceed supply limit
                revert Over_Supply(current_Minted); // reverting with custome error
            } else {
                // if (totalSupply() <= 1500 ether) {
                // supply till 1500 coins
                CoinAmount = (msg.value / 4e15) * 1 ether; // 250 coins for 1 ether
                current_Minted += CoinAmount; // current mint amount
                _mint(_to, CoinAmount); // minting tokens
                    // }
            }
        } else {
            if (block.timestamp > second_Sale && block.timestamp >= general_Sale) {
                // supply greater than 2100 billion
                if (
                    current_Minted >= Max_Supply // checking supply to not exceed max limit
                ) {
                    revert Over_Supply(current_Minted); // reverting with custome error
                }
                // if supply not exceed max limit then mint
                else {
                    CoinAmount = (msg.value / 1e16) * 1 ether; // 100 coins / 1 Eth
                    current_Minted += CoinAmount; // current mint amount
                    _mint(_to, CoinAmount); // minting
                    require(current_Minted <= Max_Supply, "Minting cannot exceed MaxSupply"); // limiting minting to maximum supply
                }
            }
        }
        return msg.sender;
    }

    function CurrentMintedAmount() external view returns (uint256) {
        return (current_Minted / 1e18);
    }

    function burn_token(uint256 value) external {
        // ERC20.balanceOf(msg.sender); // check balance of user after burning
        _burn(msg.sender, value); // burning tokens for sender
    }
}
