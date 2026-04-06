// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import {DcentralStable} from "src/ERC20Main.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
// import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract DSCEngine is ReentrancyGuard {
    // using SafeERC20 for IERC20;
    // mapping;

    mapping(address token => address PriceFeed) private collateral_Feed; // token to pricefeed mapping
    mapping(address user => uint256 token) public tokenMinted; // user minted token mapping
    mapping(address user => mapping(address token => uint256 amount)) public tokenDeposited; // user token deposit mapping
    mapping(address user => mapping(address Collateral => uint256 MintedAmount)) public DSCforCollateral; // user token minted for each collateral

    // state variable
    uint256 constant healthThreshold = 1e18;
    uint256 constant feedPrecise = 1e10;
    uint256 constant wad = 1e18; // same as 10 ** 18
    uint256 constant collateralThreshold = 65; // 65% value of collateral
    uint256 constant thresholdPrecise = 100; // ratio threshold
    uint256 constant BonusRatio = 5; // bonus percent

    DcentralStable immutable DSC; // pointer to token
    address[] public collateralToken; // array for storing token;

    // errors
    error lengthnotMatched();
    error zeroValuePassed();
    error zeroAddress();
    error transferFailed();
    error NoMintPresent();
    error HealthBroken(uint256);

    //modifier

    // modifier to check 0 value
    modifier ValueZero(uint256 value) {
        if (value == 0) revert zeroValuePassed();
        _;
    }

    // modifier to check 0 address
    modifier AddrZero(address Addr) {
        if (Addr == address(0)) revert zeroAddress();
        _;
    }

    constructor(address[] memory collateraltoken, address[] memory priceFeed, address tokenDSC) {
        // checking length equality
        if (collateraltoken.length != priceFeed.length) revert lengthnotMatched(); // revert if length not matched
        for (uint256 i; i < collateraltoken.length; i++) {
            collateral_Feed[collateraltoken[i]] = priceFeed[i]; // assigning feed to collateral
            collateralToken.push(collateraltoken[i]); // populating collateral token feeds
        }
        DSC = DcentralStable(tokenDSC); // deploy dsc token
    }

    function depositCollateralandMint(address collateral, uint256 amount) external {
        depositCollateral(collateral, amount); // calling function
        uint256 amountToMint = getMintableAgainstCollateral(msg.sender, collateral); // getting amount of mint capacity against each Collateral
        DSCforCollateral[msg.sender][collateral] += amountToMint; // adding mintedTokens against each collateral

        mintDSC(collateral); // calling mint function
    }

    function depositCollateral(address collateral, uint256 amount)
        public
        ValueZero(amount)
        AddrZero(collateral)
        nonReentrant
    {
        tokenDeposited[msg.sender][collateral] += amount; // adding collateral to mapping

        // IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount); // using safetransferfrom same as below
        bool success = IERC20(collateral).transferFrom(msg.sender, address(this), amount); // transfering from user to this contract
        if (!success) revert transferFailed(); // revert if transfer failed
    }

    function mintDSC(address collateral) public AddrZero(collateral) {
        if (tokenDeposited[msg.sender][collateral] != 0) {
            // checking if deposit present before minting
            uint256 amountToMint = getMintableAgainstCollateral(msg.sender, collateral); // getting mint capacity
            tokenMinted[msg.sender] += amountToMint; // adding tokens to mapping
            DSCforCollateral[msg.sender][collateral] += amountToMint; // adding mintedTokens against each collateral

            DSC.mint(msg.sender, amountToMint); // minting tokens for sender
            revertforBrokenHealthFactor(msg.sender); // check for health factor
        } else {
            revert zeroValuePassed();
        }
    }

    function redeemCollateralandBurnDSC() public nonReentrant {
        // loop to get balance of all collaterals
        for (uint256 i; i < collateralToken.length; i++) {
            uint256 collateralBalance = tokenDeposited[msg.sender][collateralToken[i]]; // caching balance for collateral
            uint256 amounttoBurned = DSCforCollateral[msg.sender][collateralToken[i]]; // getting tokens minted for each collateral
            if (amounttoBurned == 0) continue; // if no token minted skip the iteration

            redeemCollateral(collateralToken[i], collateralBalance); //calling redeem function function
        }
    }

    function redeemCollateral(address collateral, uint256 amount) public ValueZero(amount) AddrZero(collateral) {
        uint256 collateralValue = collateralUSDValue(collateral, amount); // getting fiat Value for collateral
        if (DSCforCollateral[msg.sender][collateral] != 0) {
            // check if any stable minted
            uint256 AmountToBurned = collateralValue * collateralThreshold / thresholdPrecise; // getting stable tokens to be burned
            _burnDSC(msg.sender, collateral, AmountToBurned); // burning stable tokens
        }

        _redeemCollateral(collateral, msg.sender, msg.sender, amount); //calling redeem function                                                                                                                                                                                                                                                                                                                                                                           ``````````````````````````````````````````  xx
    }

    function BurnDSC(address collateral, uint256 amount) public AddrZero(collateral) ValueZero(amount) {
        _burnDSC(msg.sender, collateral, amount); //calling burn pvt function
        revertforBrokenHealthFactor(msg.sender); // checking for health
    }

    function liquidateUser(address collateral, address user) external AddrZero(collateral) nonReentrant {
        uint256 startingHealthFactor = checkHealth(user); // getting user health
        if (healthThreshold > startingHealthFactor) {
            // liquidate onl if user health is below threshold
            uint256 LiquidationCollateral = tokenDeposited[user][collateral]; // caching deposited collateral
            uint256 TokenstoBurned = DSCforCollateral[user][collateral]; // getting tokens to be burned

            _burnDSC(user, collateral, TokenstoBurned); // call burn function
            _redeemCollateral(collateral, user, msg.sender, LiquidationCollateral); // redeeming collateral from user to liquidator
            TokenstoBurned = DSCforCollateral[user][collateral]; // getting tokens to be burned

            if (TokenstoBurned != 0) {
                // checks if tokens stills present
                uint256 endHealthFactor = checkHealth(user); // getting user health
                if (endHealthFactor <= startingHealthFactor) revert HealthBroken(endHealthFactor); // revert if health broken
            }
        }

        revertforBrokenHealthFactor(msg.sender); // getting liquidator health
    }

    function _redeemCollateral(address collateral, address from, address to, uint256 amount) private {
        revertforBrokenHealthFactor(to); // check for health factor
        tokenDeposited[from][collateral] -= amount; // deducting tokens to mapping

        bool success = IERC20(collateral).transfer(to, amount); // transfering from user to this contract
        if (!success) revert transferFailed(); // revert if trasnsfer failed
    }

    function _burnDSC(address to, address collateral, uint256 amount) private {
        if (tokenMinted[to] == 0) revert NoMintPresent(); // revert if no mint present
        tokenMinted[to] -= amount; // reducing tokens to mapping
        DSCforCollateral[to][collateral] -= amount; // removing mintedTokens against each collateral

        bool success = DSC.transferFrom(to, address(this), amount); // transfering from user to this contract
        if (!success) revert transferFailed(); // revert if transfer failed

        DSC.burn(amount); // burning tokens for sender
    }

    function revertforBrokenHealthFactor(address user) internal view returns (uint256) {
        uint256 healthRatio = checkHealth(user); // call function
        if (healthRatio < healthThreshold) revert HealthBroken(healthRatio); // sanity check for health
        return healthRatio;
    }

    function getMintableAgainstCollateral(address user, address CollateralToken)
        public
        view
        AddrZero(CollateralToken)
        returns (uint256)
    {
        uint256 CollateralAmount = tokenDeposited[user][CollateralToken]; // getting collateral deposited
        uint256 CollateralValueInFiat = collateralUSDValue(CollateralToken, CollateralAmount); // getting fiat Value of Collateral

        uint256 mintableTokens = (CollateralValueInFiat * collateralThreshold / thresholdPrecise); // calculating mintable tokens
        return mintableTokens;
    }

    function getMintableTokens(address user) public view returns (uint256) {
        (uint256 DSCMinted, uint256 CollateralFiatValue) = accountInfo(user); //calling function to get userInfo
        uint256 mintableAdjust = (CollateralFiatValue * collateralThreshold / thresholdPrecise); // calculating mintable tokens
        uint256 mintableTokens = mintableAdjust - DSCMinted; // Get value of token after threshold
        return mintableTokens;
    }

    function checkHealth(address user) public view returns (uint256) {
        (uint256 DSCMinted, uint256 CollateralFiatValue) = accountInfo(user); //calling function to get userInfo
        uint256 adjustedValue = CollateralFiatValue * collateralThreshold / thresholdPrecise; // Get value of token after threshold
        uint256 userHealth;
        if (DSCMinted == 0) {
            userHealth = adjustedValue / 1; // getting health factor when no mint
        } else {
            userHealth = adjustedValue * wad / DSCMinted; // getting health factor after mint
        }
        return userHealth;
    }

    function accountInfo(address user) internal view returns (uint256 DSCMinted, uint256 CollateralFiatValue) {
        DSCMinted = tokenMinted[user]; // getting minted token
        CollateralFiatValue = getCollateralValue(user); // get fiat Value of collateral
    }

    function getCollateralValue(address user) public view returns (uint256 CollateralFiatValue) {
        for (uint256 i; i < collateralToken.length; i++) {
            address token = collateralToken[i]; // getting address of token
            uint256 collateralValue = tokenDeposited[user][token]; // collatral deposited by token
            CollateralFiatValue += collateralUSDValue(token, collateralValue); // caling function and populating value
        }
        return CollateralFiatValue;
    }

    function collateralUSDValue(address token, uint256 collateralAmount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(collateral_Feed[token]); // passing aggregator token address
        (, int256 price,,,) = priceFeed.latestRoundData(); // calling function to get Latest Data
        uint256 FiatValue = (uint256(price) * feedPrecise) * collateralAmount / wad; // price in uint
        return FiatValue;
    }

    function FiattoWEIconvert(address collateral, uint256 FiatValue)
        public
        view
        ValueZero(FiatValue)
        AddrZero(collateral)
        returns (uint256)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(collateral_Feed[collateral]); // passing aggregator token address
        (, int256 price,,,) = priceFeed.latestRoundData(); // calling function to get Latest Data
        uint256 WeiValue = (FiatValue * wad) / (uint256(price) * feedPrecise); // price in uint
        return WeiValue;
    }
}
