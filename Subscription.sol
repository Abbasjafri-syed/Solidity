// SPDX-License-Identifier: None

pragma solidity ^0.8.14;

// IERC20 interface is imported to facilitate in transferring funds from projects written in Solidity
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @devs The main motivation for developing writing this subscription
// contract is providing businesses to easily receive funds in
// their desire crypto currency without need for any institution and
// paying them commission or fees to use their platform.


contract subscription_Services {
    uint public nextPlanId; // After every new plan is created by a vendor it will be incremented to give all plans a unqiue ID
    uint private MonthlyPlan = 30 days; // Defining time interval of Monthly plan after which payment will be required; can be customised according to plan model

    struct Plan {
        // This struct is used to create Subscription plan by any vendor or merchant.

        address merchant; // Merchant will put thier address where they want to receive the subscription amount.
        address token; // Address of tokens in which the amount have to be received i.e., BUSD or Matic.
        string PlanType; // Defining type of plan created in text i.e., Monthly or Yearly.
        uint amount; // Token amount that will be charged for every plan i.e., 10 token for monthly subscription. Token value must be entered with their decimals.
        uint time_Frequency; // Time interval after which payment will be required to continue the services.
    }

    struct Subscription {
        // This struct will store information of subscriber

        address user; // Address of subscriber
        uint start; // Time when the service is subcribed. Note the time are in seconds and can be viewed using epoch convertor.
        uint nextPayment; // Time when the subscription will end and payment become due.
    }

    // This mapping store data of every subscription plan created in indexed form.
    mapping(uint => Plan) public plans;

    // This mapping stores data of subscriber for a particular plan.
    mapping(address => mapping(uint => Subscription)) public subscriptions;

    // This event will be transmitted every time a new plan is created by a vendor.
    event PlanCreated(address merchant, uint planId, uint date);

    // This event will be transmitted every time a new user subscribe to a plan.
    event SubscriptionCreated(address user, uint planId, uint date);

    // This event will be transmitted every time a user cancel their subscription of a plan.
    event SubscriptionCancelled(address user, uint planId, uint date);

    // This event will be transmitted every time a user subscribes to a new plan or made payment ot their existing plan.
    event PaymentSent(
        address user,
        address merchant,
        uint amount,
        uint planId,
        uint date
    );

    // modifier to ensure address is EOA or Smart contract to create or subscribe to a plan.
    modifier verifyAddress() {
        require(
            msg.sender != address(0),
            "Null address not allowed to interact"
        );
        _;
    }

    // Function to be used by vendors in developing their own subscription payment model Plan.
    function create_Custom_Plan(
        address token, // Param of address of the crypto token in which payment is required.
        string memory PlanType, // Param defining type of plan in text form i.e., weekly or Yearly.
        uint amount, // Param defining amount of tokens for plan, needed to be mentioned with decimals for every token.
        uint time_Frequency // Param of time interval of each plan, mentioned in seconds (use convertor to avoid error).
    ) 
    external verifyAddress {
    
        // Check-interactions defining amount required for each plan, needs to be enetred with decimals
        require(amount > 100, "amount needs to be more than 100 wei");
        require(
            time_Frequency >= 10,
            "time needs to be equal or more than 1 day- 86400 SECONDS"
        ); // Check-effects interactions defining time interval for each plan needs to be entered in seconds (use convertor to avoid error).
        plans[nextPlanId] = Plan( // all params are linked to arguments
            msg.sender, // address of merchant
            token,
            PlanType,
            amount,
            time_Frequency
        ); // taking arguments and storing them in mapping in chronological order.

        nextPlanId++; // incrementing plan count ID after every new plan is generated.
    }

    // Function to be used by vendors in developing Monthly subscription payment model Plan.
    function create_Monthly_Plan(address token, string memory PlanType)
        external
        verifyAddress // The whole code works similar to above with exception of amount and time interval
    {
        // extending struct Plan where subscription plan created information will be save
        plans[nextPlanId] = Plan(
            msg.sender,
            token,
            PlanType,
            10e18, // amount is hard coded for 10 tokens with 18 decimals.
            MonthlyPlan // time interval is fixed for 30 days for paying subscription fees.
        );

        // emitting event of plan created
        emit PlanCreated(msg.sender, nextPlanId, block.timestamp);

        nextPlanId++; // incrementing plan count
    }

    // function for users to begin their subscription for a particular plan
    function subscribe(uint planId) external verifyAddress {
        // creating pointer to the token on which payment has to be made using ERC20 interface applicable to both simple and Upgradeable edition
        IERC20 token = IERC20(plans[planId].token);

        // pointer for the plan on which the subscription has to be made
        Plan storage plan = plans[planId];

        // token will be transferred after subscription from user aka msg.sender to the merchant with amount of token specified
        token.transfer(plan.merchant, plan.amount);

        // after token are transferred these code will operate
        unchecked {
            emit PaymentSent( // emitting event of payment sent
                msg.sender, // subscriber
                plan.merchant, // merchant of specific plan
                plan.amount, // amount sent for a specific plan
                planId, // ID of the plan
                block.timestamp // time when payment is sent needs to converetd using epoch convertor
            );

            // extending struct Subscription where information of subscriber will be stored
            subscriptions[msg.sender][planId] = Subscription(
                msg.sender, // user subcribing to a plan
                block.timestamp, // time when subscription started
                block.timestamp + plan.time_Frequency // time of subscription ending
            );

            // emitting event of when a subscription is created
            emit SubscriptionCreated(msg.sender, planId, block.timestamp);
        }
    }
   
    //  function to be called by subscriber to pay for continuity of their plan
    function pay(address user, uint planId) external {
        //pointer towards Subscription for which the payment has to be made by user
        Subscription storage subscription = subscriptions[user][planId];

        // pointer towards Plan storing plan created
        Plan storage plan = plans[planId];

        // pointer towards token address on which the payment will be made
        IERC20 token = IERC20(plan.token);

        // check-effect interaction to check only subscriber can made payment for their plan
        require(
            msg.sender == subscription.user,
            "Kindly enter your own address or subscribe to service before making any payment"
        );

        // check-effect interaction so that next payment is made after subscription time ends
        require(
            block.timestamp > subscription.nextPayment,
            "Payment is not due yet"
        );

        // token will be transferred to merchant after they initialise the pay function to made payment due for specific plan
        token.transfer(plan.merchant, plan.amount);

        // the below logic will proceed after payment is made for the plan
        unchecked {
            // emitting event for payment made by subsriber
            emit PaymentSent(
                user,
                plan.merchant,
                plan.amount,
                planId,
                block.timestamp
            );

            // calculating next payment due time by adding time interval defined for the particular plan
            subscription.nextPayment =
                subscription.nextPayment +
                plan.time_Frequency;
        }
    }

    // function to be called by users for cancelling their subscription
    function cancel(uint planId) external {
        // param to mention specific plan for cancelling

        // pointer to Subscription plan required to be cancelled
        Subscription storage subscription = subscriptions[msg.sender][planId];

        // check-effect interaction for security so that only subscriber can cancel their subscription
        require(
            msg.sender == subscription.user,
            "Only Subscriber can cancel their subscription"
        );

        //deleting record of user from a Subscription struct for a particular plan
        delete subscriptions[msg.sender][planId];

        // emitting event after the plan is cancelled by the subscriber
        emit SubscriptionCancelled(msg.sender, planId, block.timestamp);
    }
}
