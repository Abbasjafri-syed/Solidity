// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";

import {DcentralStable} from "src/ERC20Main.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract FuzzHandler is Test {
    DcentralStable DSC;
    DSCEngine engine;
    ERC20Mock WBTC;
    ERC20Mock WETH;

    uint256 Max_Value = type(uint64).max; // ,aximum limit for deposit
    address user = makeAddr("USER");

    constructor(DcentralStable dsc, DSCEngine DscEngine) {
        DSC = dsc; // getting contract address
        engine = DscEngine;

        address[] memory collateral = engine.getCollaterals();
        WBTC = ERC20Mock(collateral[0]); // getting token at index 0
        WETH = ERC20Mock(collateral[1]); // getting token at index 1
    }

    function engineDeposit(uint256 CollateralIndex, uint256 Amount) public {
        ERC20Mock collateral = getIndexCollateral(CollateralIndex); // getting token
        Amount = (bound(Amount, 1, Max_Value) * 1 ether); // limit for min and max amount
        // console.log('Amount: %e', Amount);

        vm.startPrank(user); // call initiating
        collateral.mint(user, Amount); // minting tokens
        collateral.approve(address(engine), Amount); // approving tokens to contract
        engine.depositCollateral(address(collateral), Amount); // calling deposit function
            // vm.stopPrank();
    }

    function getIndexCollateral(uint256 CollateralIndex) private view returns (ERC20Mock) {
        if (CollateralIndex % 2 == 0) {
            // condition to return address
            return WBTC; // return wbtc if value is even
        }
        return WETH; // return weth if value is odd
    }

    function collateralredeem(uint256 CollateralIndex, uint256 Amount) external {
        ERC20Mock collateral = getIndexCollateral(CollateralIndex); // getting token
        engineDeposit(CollateralIndex, Amount); // calling deposit function
        uint256 collateralDeposited = engine.tokenDeposited(user, address(collateral)); // getting collateral deposited

        Amount = bound(Amount, 1, collateralDeposited); // bounding for limit

        vm.startPrank(user); // call initiating
        collateral.approve(address(engine), Amount); // approving tokens to contract

        engine.redeemCollateral(address(collateral), Amount); // call redeem function
    }
// causing error as it is called more than once in a single call
    // function mintDsc(uint256 CollateralIndex, uint256 Amount) external {
    //     ERC20Mock collateral = getIndexCollateral(CollateralIndex); // getting token
    //     engineDeposit(CollateralIndex, Amount); // calling deposit function
    //     uint256 collateralDeposited = engine.tokenDeposited(user, address(collateral)); // getting collateral deposited

    //     uint256 ValueInUSD = engine.collateralUSDValue(address(collateral), collateralDeposited); // getting collateral in USD

    //     uint256 collateralMint = ValueInUSD * 65 / 100; // getting mint capacity
    //     console.log("Collateral Mint Capacity: %e", collateralMint);

    //     vm.startPrank(user); // call initiating
    //     engine.mintDSC(address(collateral)); // call mint function

    //     uint256 MintedToken = engine.tokenMinted(user); // token minted by a user against collateral
    //     console.log("Minted Token: %e", MintedToken);
    // }
}
