// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract rafflePractice is VRFConsumerBaseV2, Ownable {
    error less_Amount();
    error lastWinner_NotAllowed();
    error participant_presents();
    error value_NotUpdated();
    error upKeep_notRequired(uint256 contract_balance, uint256 funder_count, uint256 raffle_Status);

    event raffleCreated(uint256 indexed raffle_Count); // event for every raffle created
    event raffleFunder(address indexed funder_address); // event for every funder entering raffle

    enum raffle_Status { // creating a custom data type known as enum similar to bool or uint
        not_Exists,
        Exists
    }

    raffle_Status public current_State; // pointer var towards enum type
    AggregatorV3Interface USDC; // chainlink usdc address feed
    VRFCoordinatorV2Interface COORDINATOR; // coordinator account for getting random number

    address[] public Participants; // array of all participant
    address public winner_Update; // last winner
    // address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // vrf address chainlink

    mapping(address funder => uint256 Count) public ticket_Count; // increment ticket count for an address
    mapping(address funder => uint256 Count) public token_amount; // add ticket amount for every entry

    uint256 immutable ticket_Price; // ticket price
    uint256 time_Started; // start time
    uint256 public time_Ended; // end time of raffle
    uint256 public last_randomValue; // last value from vrf
    uint256 public latest_randomValue; // latestrandom value from vrf
    uint256 public raffleCount; // creating count for every raffle

    uint64 s_subscriptionId; //
    uint32 callbackGasLimit;
    // gas limit for callback fulfillRandomWords
    uint32 numWords; // numbr of random words
    uint16 requestConfirmations; // number of block confirms

    bytes32 s_keyHash; // gas lane hash value

    constructor(
        address chainlink_Feed,
        uint256 price,
        address coordinator_vrf,
        bytes32 hash,
        uint32 call_Limit,
        uint16 confirmations,
        uint32 num_Values,
        uint64 subscriptionId
    ) Ownable() VRFConsumerBaseV2(coordinator_vrf) {
        USDC = AggregatorV3Interface(chainlink_Feed); // sepolia usdc address
        ticket_Price = price; // setting ticket price to 1 dollar
        COORDINATOR = VRFCoordinatorV2Interface(coordinator_vrf);
        s_keyHash = hash;
        callbackGasLimit = call_Limit;
        requestConfirmations = confirmations; // lower than 3 confirmation causes vrf call to revert
        numWords = num_Values; // only 1st index is called more cause txn to stuck
        s_subscriptionId = subscriptionId;
    }

    function create_Raffle() external onlyOwner {
        require(current_State == raffle_Status.not_Exists, "raffle already exists"); // changing raffle status

        current_State = raffle_Status.Exists; // changing state
        time_Started = block.timestamp; // start time
        time_Ended = time_Started + 4 minutes; //  end time
        emit raffleCreated(raffleCount);
        raffleCount++;
    }

    function enterRaffle() external payable {
        require(current_State == raffle_Status.Exists, "Raffle does Not exists"); // check raffle status
        require(block.timestamp < time_Ended, "raffle has Ended"); // require current time to be less than end time

        uint256 tokenPrice = price_Convert(msg.value); // converting value into usd
        //  if (msg.value < ticket_Price) { // remix check
        if (tokenPrice < ticket_Price) {
            // testnet check
            //  if value is less than revert
            revert less_Amount();
        }
        if (tokenPrice > ticket_Price) {
            // for testnet
            //  if value is greater than ticket price call refund
            refund(tokenPrice); // calling refund function to return excess amount
        }
        Participants.push(msg.sender); // adding funder to array
        ticket_Count[msg.sender]++; // adding winner
        emit raffleFunder(msg.sender); // emiting event when for funder
    }

    // create refund for excess amount
    function refund(uint256 tokenPrice) internal {
        uint256 usdPrice = price_Feed(); // getting USDC token price in usd
        uint256 amountDifference = tokenPrice - ticket_Price; // getting amount to be refunded
        uint256 amountRefund = (amountDifference * 1e18) / usdPrice; // converting usd into eth 1e18
        // token_amount[msg.sender] += ((tokenPrice - amountDifference) * 1e18) / usdPrice; // amount added in msg.value
        token_amount[msg.sender] += tokenPrice - amountDifference; // amount as per ticket price

        (bool success,) = msg.sender.call{value: amountRefund}(""); // sending back additional amount
        require(success);
    }

    function Raffle_Winner() external onlyOwner {
        require(block.timestamp > time_Ended + 12 seconds, "raffle does not end"); // checking time
        require(current_State == raffle_Status.Exists, "Raffle winner draw"); // check raffle status
        require(latest_randomValue != last_randomValue, "last vaue cannot be used"); // checking latest value

        //  add modulo to have select a random winner
        uint256 random_Value = (
            uint256(keccak256(abi.encode(latest_randomValue, block.timestamp, Participants.length)))
                % Participants.length
        ); // get a random number with limit related to number of participants

        // last winner cannot win raffle twice
        if (Participants[random_Value] == winner_Update) {
            revert lastWinner_NotAllowed();
        }

        reset_Mappings(); // calling function to reset all mapping
        winner_Update = Participants[random_Value]; // update winner
        Participants = new address[](0); // setting the array to zero
        current_State = raffle_Status.not_Exists; // resetting status back to false;
        last_randomValue = latest_randomValue; // after winner caching value

        // transferring raffle balance to winner
        (bool success,) = winner_Update.call{value: address(this).balance}("");
        require(success, "Txn failed");
    }

    function check_UpKeep(bytes memory /* check*/ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* perform */ )
    {
        // function for performing upkeep
        bool time_Interval = block.timestamp > time_Ended; // checking time ended
        bool active_Raffle = current_State == raffle_Status.Exists; // raffle status check
        bool funder_participant = Participants.length > 0; // checking participant presence
        bool funds = address(this).balance > 0; // checking contract balance

        upkeepNeeded = (time_Interval && active_Raffle && funder_participant && funds); // caching all values to be returned
        return (upkeepNeeded, "0x00"); // returning values
    }

    function genrt_random() external returns (uint256) {
        (bool upkeep,) = check_UpKeep(""); // checking upkeep condition
        if (!upkeep) {
            // reverting if any condition not met
            revert upKeep_notRequired(address(this).balance, Participants.length, uint256(current_State)); // revert with values
        }
        uint256 random_Value = (
            uint256(keccak256(abi.encode(latest_randomValue, block.timestamp, Participants.length, msg.data)))
                % Participants.length
        ) + 1; // to get value within teh range of all funders if +1 is not insert will leave last funder
        latest_randomValue = random_Value; // assigning value to variable
        return random_Value; // returning latest value
    }

    function getRandom() external returns (uint256 requestId) {
        // requesting random number from chainlink vrf
        // Will revert if subscription is not set and funded.
        (bool upkeep,) = check_UpKeep(""); // checking upkeep value
        if (!upkeep) {
            // reverted if upkeep return false
            revert();
        }
        requestId = COORDINATOR.requestRandomWords( // requesting random value from chainlink vrf
        s_keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
        return requestId; // request made
    }

    function fulfillRandomWords( // callback function for getting random number
    uint256, /* requestId */ uint256[] memory randomWords)
        internal
        override
    {
        uint256 ranValue = randomWords[0]; // only 1st index of random value can be called otherwise txn get pending
        if (ranValue == last_randomValue && ranValue == 0) {
            // checking if vrf returns the value
            revert value_NotUpdated();
        }
        latest_randomValue = ranValue; // caching latest value
    }

    function getrandomValue() external view returns (uint256) {
        // getting random value
        return latest_randomValue;
    }

    function reset_Raffle() external onlyOwner {
        //resetting waffle if no participation
        require(block.timestamp > time_Ended, "Raffle does not end"); // checking time before resetting
        if (Participants.length == 0) {
            // if no participant change status
            current_State = raffle_Status.not_Exists;
        } else {
            // if participants present reverts
            revert participant_presents();
        }
    }

    function reset_Mappings() internal {
        // function to delete mapping
        for (uint256 i = 0; i < Participants.length; ++i) {
            // running loop on every Participants length
            address participant = Participants[i]; // caching arrat length
            delete ticket_Count[participant]; // deleting value
            delete token_amount[participant]; // resetting value to zero
        }
    }

    // get price difference
    function price_Convert(uint256 tokenAmount) internal view returns (uint256) {
        uint256 USDC_Price = price_Feed(); // get feed price
        uint256 price_USD = (tokenAmount * USDC_Price) / 1e18; // converting msg.value into USD
        return price_USD; // returning amount into USD
    }

    function funders_Length() external view returns (uint256) {
        return Participants.length;
    }

    // add chainlink aggregator price feed
    function price_Feed() internal view returns (uint256) {
        (, int256 price,,,) = USDC.latestRoundData(); // get price through chainlink feed
        return uint256(price * 1e10); // making price 1e18 to make compatible with evm
    }
}
