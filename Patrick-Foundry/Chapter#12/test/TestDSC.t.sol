// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {DcentralStable} from "src/ERC20Main.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {deployScript} from "script/Deploy.s.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract TestDsc is Test {
    DcentralStable DSC; // pointer to contract
    DSCEngine engine;
    HelperConfig config;
    deployScript deployer;
    address WBTCfeed;
    address WETHfeed;
    address WBTC;
    address WETH;

    address user = makeAddr("USER`");
    address Liquidator = makeAddr("Liquidator");
    uint256 mintedToken = 100e18;

    function setUp() external {
        deployer = new deployScript(); // deploying contract
        (DSC, engine, config) = deployer.run();
        (WBTCfeed, WETHfeed, WBTC, WETH,) = config.ActiveNetworkConfig();
    }

    // forge t --mt test_info -vvv
    function test_info() external view {
        console.log("WBTCfeed address:", WBTCfeed);
        console.log("WBTC address:", WBTC);
        console.log("WETHfeed address:", WETHfeed);
        console.log("WETH address:", WETH);
    }

    // forge t --mt test_TokenPrice -vvv
    function test_TokenPrice() external view {
        uint256 tokenAmount = 5;

        uint256 ETHValue = engine.collateralUSDValue(WETH, tokenAmount);
        assertEq(ETHValue, 1e4);

        uint256 BTCValue = engine.collateralUSDValue(WBTC, tokenAmount);
        assertEq(BTCValue, 5e4);
    }

    // forge t --mt test_FiatWei -vvv
    function test_FiatWei() external view {
        uint256 FiatValue = 100e18;
        uint256 valueinWei = engine.FiattoWEIconvert(WBTC, FiatValue);
        console.log("WBTC Wei Value Token: %e", valueinWei);
        assertEq(valueinWei, 1e16);

        uint256 FiatWethValue = 2000e18;

        valueinWei = engine.FiattoWEIconvert(WETH, FiatWethValue);
        console.log("WETH Wei Value Token: %e", valueinWei);
        assertEq(valueinWei, 1e18);
    }

    // forge t --mt test_mintERCtokens -vvv
    function test_mintERCtokens() public {
        vm.startPrank(user);
        ERC20Mock(WBTC).mint(user, mintedToken); // minting WBTC
        ERC20Mock(WETH).mint(user, mintedToken); // minting WETH

        uint256 Weth_Balance = ERC20Mock(WBTC).balanceOf(user);
        uint256 BTC_Balance = ERC20Mock(WETH).balanceOf(user);

        assertEq(Weth_Balance, mintedToken);
        assertEq(BTC_Balance, mintedToken);
    }

    // forge t --mt test_despositandgetuserBalance -vvv
    function test_despositandgetuserBalance() public {
        uint256 tokenAmount = 5e18;

        uint256 userBalance = engine.getCollateralValue(user);
        assertEq(userBalance, 0);

        test_mintERCtokens(); // mint collateral value

        vm.startPrank(user);
        ERC20Mock(WBTC).approve(address(engine), mintedToken);
        engine.depositCollateral(WBTC, tokenAmount); // deposit collateral

        userBalance = engine.getCollateralValue(user); // get deposit value
        assertEq(userBalance, 5e22);

        ERC20Mock(WETH).approve(address(engine), mintedToken);
        engine.depositCollateral(WETH, tokenAmount);

        userBalance = engine.getCollateralValue(user);
        assertEq(userBalance, 6e22);
    }

    // forge t --mt test_userMintValue -vvv
    function test_userMintValue() public {
        test_despositandgetuserBalance();

        uint256 userWETHMint = engine.getMintableAgainstCollateral(user, WETH);
        console.log("User WETH mint capacity: %e", userWETHMint);

        uint256 userWBTCMint = engine.getMintableAgainstCollateral(user, WBTC);
        console.log("User WBTC mint capacity: %e", userWBTCMint);

        uint256 TotalMint = engine.getMintableTokens(user);
        assertEq(TotalMint, userWETHMint + userWBTCMint);
    }

    // forge t --mt test_checkUserHealthAfterWeth -vvv
    function test_checkUserHealthAfterWeth() public {
        test_userMintValue();

        vm.startPrank(user);

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health Before Mint:  %e", userHealth);

        engine.mintDSC(WETH);

        uint256 userBalance = IERC20(DSC).balanceOf(user);
        console.log("user Balance after Weth Mint: %e", userBalance);

        uint256 userMint = engine.getMintableTokens(user);
        console.log("User mint capacity After Weth: %e", userMint);

        userHealth = engine.checkHealth(user);
        console.log("user Health after WETH Mint:  %e", userHealth);
    }

    // forge t --mt test_checkUserHealthAfterWBTC -vvv
    function test_checkUserHealthAfterWBTC() external {
        test_checkUserHealthAfterWeth(); // calling function

        vm.startPrank(user);

        engine.mintDSC(WBTC);

        uint256 userBalance = IERC20(DSC).balanceOf(user);
        console.log("user Balance after WBTC: %e", userBalance);

        uint256 userMint = engine.getMintableTokens(user);
        console.log("User mint capacity: %e", userMint);

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health after WBTC Mint:  %e", userHealth);
    }

    // forge t --mt test_depositZeroCollateral -vvv
    function test_depositZeroCollateral() public {
        test_mintERCtokens();

        vm.expectRevert(DSCEngine.zeroValuePassed.selector); // expecting revert with error
        engine.depositCollateral(address(WBTC), 0); // calling function deposit with 0 value
    }

    // forge t --mt test_mintZeroValue -vvv
    function test_mintZeroValue() external {
        test_depositZeroCollateral();

        vm.expectRevert(DSCEngine.zeroValuePassed.selector);
        engine.mintDSC(WETH); // calling function without deposited
    }

    // forge t --mt test_DepositandMint -vvv
    function test_DepositandMint() external {
        test_mintERCtokens(); // mint collateral value

        uint256 tokenAmount = 5e18;
        ERC20Mock(WBTC).approve(address(engine), mintedToken); // approving token to contract

        engine.depositCollateralandMint(WBTC, tokenAmount); //depositing  wbtc and minting tokens

        uint256 TokenDeposited = engine.tokenDeposited(user, WBTC); // getting token deposited into contract
        assertEq(TokenDeposited, tokenAmount);

        uint256 TokenMinted = engine.tokenMinted(user); // getting token deposited
        console.log("Token Minted: %e", TokenMinted);

        uint256 afterMint = engine.getMintableTokens(user); // get mintable capacity
        assertEq(afterMint, 0);
    }

    // forge t --mt test_mintNoDeposit -vvv
    function test_mintNoDeposit() external {
        vm.startPrank(user);

        vm.expectRevert(DSCEngine.zeroValuePassed.selector);
        engine.mintDSC(WETH);
    }

    // forge t --mt test_ValueWBTC -vvv
    function test_ValueWBTC() public {
        test_despositandgetuserBalance();

        uint256 WBTCDeposited = engine.tokenDeposited(user, WBTC); // getting depsoited amount of token

        uint256 DepositedValue = engine.collateralUSDValue(WBTC, WBTCDeposited); // deposit amount in Fiat
        assertEq(DepositedValue, 5e22);
    }

    // forge t --mt test_userHealthNoMint -vvv
    function test_userHealthNoMint() external {
        test_ValueWBTC();
        uint256 UserHealth = engine.checkHealth(user);
        console.log("UserHealth: %e", UserHealth);
    }

    // forge t --mt test_redeemWbtc -vvv
    function test_redeemWbtc() external {
        test_ValueWBTC();
        uint256 initBalance = IERC20(WBTC).balanceOf(user);
        // console.log("initBalance: %e", initBalance);

        uint256 WBTCDeposited = engine.tokenDeposited(user, WBTC);

        engine.redeemCollateral(address(WBTC), WBTCDeposited);

        uint256 endBalance = IERC20(WBTC).balanceOf(user);
        // console.log("endBalance: %e", endBalance);
        assertEq(endBalance, initBalance + 5e18);
    }

    // forge t --mt test_ValueWeth -vvv
    function test_ValueWeth() public {
        test_despositandgetuserBalance();

        uint256 WETHDeposited = engine.tokenDeposited(user, WETH); // getting depsoited amount of token

        uint256 DepositedValue = engine.collateralUSDValue(address(WETH), WETHDeposited);
        // console.log("WBTC Vlaue: %e", DepositedValue);
        assertEq(DepositedValue, 1e22);
    }

    // forge t --mt test_redeemWeth -vvv
    function test_redeemWeth() external {
        test_ValueWeth();
        uint256 startBalance = IERC20(WETH).balanceOf(user);

        uint256 WETHDeposited = engine.tokenDeposited(user, address(WETH)); // getting depsoited amount of token
        engine.redeemCollateral(address(WETH), WETHDeposited); // calling redeem function

        uint256 endBalance = IERC20(WETH).balanceOf(user);

        assertEq(endBalance, (startBalance + WETHDeposited)); // validating balance of user
    }

    // forge t --mt test_redeemCollateralSplit -vvv
    function test_redeemCollateralSplit() external {
        test_despositandgetuserBalance(); // calling deposit collateral

        vm.startPrank(user);
        engine.mintDSC(WETH); // calling mint function
        engine.mintDSC(WBTC);

        uint256 startDSCBalance = IERC20(DSC).balanceOf(user); // getting DSC balance
        console.log("user DSC Balance: %e", startDSCBalance);

        uint256 DSCWETHMinted = engine.DSCforCollateral(user, WETH); // getting DSC balance
        console.log("user DSC WETH Minted: %e", DSCWETHMinted);

        uint256 DSCWBTCMinted = engine.DSCforCollateral(user, WBTC); // getting DSC balance
        console.log("user DSC WBTC Minted: %e", DSCWBTCMinted);

        uint256 userBalance = engine.getCollateralValue(user); // getting value of all collateral deposited
        console.log("user Balance Before: %e", userBalance);

        address[2] memory collateralToken = [WETH, WBTC];
        for (uint256 i; i < collateralToken.length; i++) {
            uint256 collateralBalance = engine.tokenDeposited(user, collateralToken[i]); // getting collateral deposited
            IERC20(DSC).approve(address(engine), engine.DSCforCollateral(user, collateralToken[i])); // calling approve func
            engine.redeemCollateral(collateralToken[i], collateralBalance);
        }

        userBalance = engine.getCollateralValue(user);
        console.log("user Balance After Redeem: %e", userBalance);

        DSCWETHMinted = engine.DSCforCollateral(user, WETH); // getting DSC balance
        console.log("user DSC WETH Minted: %e", DSCWETHMinted);

        DSCWBTCMinted = engine.DSCforCollateral(user, WBTC); // getting DSC balance
        console.log("user DSC WBTC Minted: %e", DSCWBTCMinted);
    }

    // forge t --mt test_redeemCollateralSingle -vvv
    function test_redeemCollateralSingle() external {
        test_despositandgetuserBalance(); // calling deposit collateral

        uint256 userBalance = engine.getCollateralValue(user); // getting value of all collateral deposited
        console.log("user Balance: %e", userBalance);

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health Before: %e", userHealth);

        vm.startPrank(user);
        engine.mintDSC(WETH); // calling mint function

        userHealth = engine.checkHealth(user);
        console.log("user Health AFTER: %e", userHealth);

        uint256 userDepositedMint = engine.DSCforCollateral(user, WETH); // getting mintable value
        console.log("User DSC for WETH capacity Before Mint: %e", userDepositedMint);

        IERC20(DSC).approve(address(engine), userDepositedMint); // calling approve func
        engine.redeemCollateralandBurnDSC();

        uint256 endDSCBalance = IERC20(DSC).balanceOf(user); // getting DSC balance after redeem and burn
        assertEq(endDSCBalance, 0);

        userDepositedMint = engine.DSCforCollateral(user, WETH); // getting mintable value
        console.log("User DSC for WETH capacity: %e", userDepositedMint);

        userBalance = engine.getCollateralValue(user); // getting value of all collateral deposited
        console.log("user Balance: %e", userBalance);

        userHealth = engine.checkHealth(user);
        console.log("user Health: %e", userHealth);
    }

    // forge t --mt test_BurnAndRedeemCollateral -vvv
    function test_BurnAndRedeemCollateral() external {
        test_despositandgetuserBalance();

        engine.mintDSC(WETH); // calling mint function
        engine.mintDSC(WBTC);

        uint256 WETHDSCMinted = engine.DSCforCollateral(user, WETH); // getting mintable capacity
        console.log("user wbtc Mint %e", WETHDSCMinted);

        uint256 WBTCDSCMinted = engine.DSCforCollateral(user, WBTC);
        console.log("user wbtc Mint: %e", WBTCDSCMinted);

        uint256 WethBalance = engine.tokenDeposited(user, WETH); // getting collateral deposited into contract
        console.log("user WETH Balance: %e", WethBalance);

        uint256 WBTCBalance = engine.tokenDeposited(user, WBTC);
        console.log("user wbtc Balance: %e", WBTCBalance);

        uint256 totalMintable = engine.tokenMinted(user); // total minted amount
        // console.log("User total Minted: %e", totalMintable);

        uint256 WethMinted = engine.DSCforCollateral(user, WETH); // weth minted
        console.log("User WETH Minted Before: %e", WethMinted);

        uint256 WBtcMinted = engine.DSCforCollateral(user, WBTC); // wbtc minted
        console.log("User WBTC Minted: %e", WBtcMinted);

        assertEq(totalMintable, WethMinted + WBtcMinted); // asserting total minted with segregate

        uint256 wethBalance = IERC20(WETH).balanceOf(user); // weth Balance
        console.log("User WETH Balance Before Redeem: %e", wethBalance);

        IERC20(DSC).approve(address(engine), WethMinted); // approving token balances
        engine.BurnDSC(WETH, WethMinted);

        WethMinted = engine.DSCforCollateral(user, WETH); // weth minted
        console.log("User WETH Minted After Burn: %e", WethMinted);

        engine.redeemCollateral(WETH, WethBalance); // redeeming collateral

        WethBalance = engine.tokenDeposited(user, WETH); // getting collateral deposited into contract
        console.log("user WETH Balance: %e", WethBalance);

        wethBalance = IERC20(WETH).balanceOf(user); // weth Balance
        console.log("User WETH Balance After Redeem: %e", wethBalance);
    }

    // forge t --mt test_BurnWithoutMint -vvv
    function test_BurnWithoutMint() external {
        test_despositandgetuserBalance(); // calling deposit collateral

        uint256 WETHDSCMintable = engine.getMintableAgainstCollateral(user, WETH); // getting mintable capacity
        // console.log("user wbtc Mintable: %e", WETHDSCMintable);

        uint256 WBTCDSCMintable = engine.getMintableAgainstCollateral(user, WBTC);
        // console.log("user wbtc Mintable: %e", WBTCDSCMintable);

        uint256 totalMintable = engine.getMintableTokens(user); // caching total mintable capacity
        assertEq(totalMintable, WETHDSCMintable + WBTCDSCMintable);

        vm.expectRevert(DSCEngine.NoMintPresent.selector); // expecting revert due to no mint
        engine.BurnDSC(WETH, WETHDSCMintable); // calling function
    }

    // forge t --mt test_AggregatorUpdatePrice -vvv
    function test_AggregatorUpdatePrice() internal {
        int256 WBTCNewValue = 8000e8;
        int256 WETHNewValue = 1000e8;

        MockV3Aggregator(WBTCfeed).updateAnswer(WBTCNewValue); // updating price of feed
        MockV3Aggregator(WETHfeed).updateAnswer(WETHNewValue);
    }

    // forge t --mt test_UserHealthAfterPriceUpdate -vvv
    function test_UserHealthAfterPriceUpdate() public {
        test_despositandgetuserBalance(); // calling deposit collateral

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health before Mint: %e", userHealth);

        vm.startPrank(user);
        engine.mintDSC(WETH); // calling mint function
        engine.mintDSC(WBTC);

        userHealth = engine.checkHealth(user);
        console.log("user Health After Mint: %e", userHealth);

        test_AggregatorUpdatePrice();

        userHealth = engine.checkHealth(user);
        console.log("user Health Price Update: %e", userHealth);
    }

    // forge t --mt test_DepositCollateralLiquidator -vvv
    function test_DepositCollateralLiquidator() public {
        vm.startPrank(Liquidator);
        ERC20Mock(WBTC).mint(Liquidator, mintedToken);
        ERC20Mock(WETH).mint(Liquidator, mintedToken);

        uint256 tokenAmount = 15e18;

        ERC20Mock(WBTC).approve(address(engine), mintedToken);
        engine.depositCollateral(WBTC, tokenAmount); // deposit collateral

        ERC20Mock(WETH).approve(address(engine), mintedToken);
        engine.depositCollateral(WETH, tokenAmount);

        uint256 LiquidatorMint = engine.getMintableAgainstCollateral(Liquidator, WETH); // getting mintable value
        console.log("Liquidator Mint Capacity: %e", LiquidatorMint);

        engine.mintDSC(WETH);
        vm.stopPrank();

        uint256 DSCBalance = IERC20(DSC).balanceOf(Liquidator);
        console.log("Liquidator DSC Balance: %e", DSCBalance);
    }

    // forge t --mt test_LiquidateUser -vvv
    function test_LiquidateUser() public {
        test_UserHealthAfterPriceUpdate();
        console.log("----------Liquidation WETH---------");

        uint256 WethDepositBalance = engine.tokenDeposited(user, WETH);
        console.log("WETH Deposited before : %e", WethDepositBalance);

        uint256 DSCBalance = IERC20(DSC).balanceOf(user);
        console.log("User DSC Balance Update: %e", DSCBalance);

        uint256 WETHMints = engine.DSCforCollateral(user, WETH);
        console.log("User DSC WETH Mint: %e", WETHMints);

        uint256 CollateralValueWETH = engine.collateralUSDValue(WETH, WethDepositBalance);
        console.log("Fiat Value of User Deposited WETH : %e", CollateralValueWETH);

        vm.stopPrank();

        test_DepositCollateralLiquidator();

        uint256 userHealthUpdated = engine.checkHealth(user);
        console.log("user Health Price Update: %e", userHealthUpdated);
        // first mint DSC
        vm.prank(user);
        IERC20(DSC).approve(address(engine), WETHMints); // calling approve func

        vm.startPrank(Liquidator);
        engine.liquidateUser(WETH, user);

        WethDepositBalance = engine.tokenDeposited(user, WETH);
        console.log("User Weth Deposit Balance After: %e", WethDepositBalance);

        WETHMints = engine.DSCforCollateral(user, WETH);
        console.log("User DSC WETH Mint After: %e", WETHMints);

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health After Update: %e", userHealth);

        DSCBalance = IERC20(DSC).balanceOf(user);
        console.log("User DSC Balance: %e", DSCBalance);

        uint256 WethBalance = IERC20(WETH).balanceOf(Liquidator);
        console.log("Liquidator WETH Balance: %e", WethBalance);

        DSCBalance = IERC20(DSC).balanceOf(Liquidator);
        console.log("Liquidator DSC Balance: %e", DSCBalance);
    }

    // forge t --mt test_BTCLiquidate -vvv
    function test_BTCLiquidate() external {
        test_LiquidateUser();

        console.log("-------------WBTC Liquidate Test-----------");

        uint256 WBTCDepositBalance = engine.tokenDeposited(user, WBTC);
        console.log("WBTC Deposited before : %e", WBTCDepositBalance);

        uint256 WBTCMints = engine.DSCforCollateral(user, WBTC);
        console.log("User DSC WBTC Mint: %e", WBTCMints);

        uint256 CollateralValueWBTC = engine.collateralUSDValue(WBTC, WBTCDepositBalance);
        console.log("Fiat Value of User Deposited WBTC : %e", CollateralValueWBTC);

        uint256 FiattoWeiConvert = engine.FiattoWEIconvert(WBTC, CollateralValueWBTC);
        console.log("Fiat Value convert to Wei : %e", FiattoWeiConvert);

        uint256 DSCBalance = IERC20(DSC).balanceOf(user);
        console.log("User DSC Balance Liquidate WBTC Before: %e", DSCBalance);

        vm.startPrank(user);
        IERC20(DSC).approve(address(engine), WBTCMints); // calling approve func

        console.log("--------------After This revert WBTC-----------");

        vm.startPrank(Liquidator);
        engine.liquidateUser(WBTC, user);

        uint256 WBTCBalance = IERC20(WBTC).balanceOf(Liquidator);
        console.log("Liquidator WBTC Balance: %e", WBTCBalance);

        WBTCDepositBalance = engine.tokenDeposited(user, WBTC);
        console.log("WBTC Deposited After User : %e", WBTCDepositBalance);

        WBTCMints = engine.getMintableAgainstCollateral(user, WBTC);
        console.log("User DSC WBTC Mint: %e", WBTCMints);

        DSCBalance = IERC20(DSC).balanceOf(user);
        console.log("User DSC Balance AFter WBTC Liquidate : %e", DSCBalance);

        uint256 userHealth = engine.checkHealth(user);
        console.log("user Health After Update: %e", userHealth);
    }
}
