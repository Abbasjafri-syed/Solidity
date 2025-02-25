// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

// testing DelegateCall https://www.rareskills.io/post/delegatecall
contract CallDelegateProxy {
    event SenderAtCalledFirst(address indexed sender);

    function delegateCallToFirst(address call_Simple, address calledSimple) external {
        call_Simple.call(abi.encodeWithSignature("logSender(address)", calledSimple)); // making delegate call to CalledFirst
            // emit SenderAtCalledFirst(msg.sender);
    }
}

contract CallSimple {
    event SenderAtCalledFirst(address indexed sender);

    function logSender(address calledSimple) external {
        emit SenderAtCalledFirst(msg.sender);
        calledSimple.delegatecall(abi.encodeWithSignature("logSender()")); // making delegate call to CalledLast
    }
}

contract SimpleCalled {
    event SenderAtCalledLast(address indexed sender);

    function logSender() external {
        emit SenderAtCalledLast(msg.sender);
    }
}

contract CallerProxy {
    event SenderAtCalledFirst(address indexed sender);

    function delegateCallToFirst(address calledFirst, address calledLast) public {
        calledFirst.delegatecall(abi.encodeWithSignature("logSender(address)", calledLast)); // making delegate call to CalledFirst
            // emit SenderAtCalledFirst(msg.sender);
    }
}

contract CalledFirst {
    event SenderAtCalledFirst(address indexed sender);

    function logSender(address calledLast) public {
        emit SenderAtCalledFirst(msg.sender);
        calledLast.delegatecall(abi.encodeWithSignature("logSender()")); // making delegate call to CalledLast
    }
}

contract CalledLast {
    event SenderAtCalledLast(address indexed sender);

    function logSender() public {
        emit SenderAtCalledLast(msg.sender);
    }
}

contract Callerslot {
    uint256 public price = 200;

    error Delegatefailed(); // custom error

    function setDiscount(address called) public {
        (bool success, bytes memory data) =
            called.delegatecall(abi.encodeWithSignature("calculateDiscountPrice(uint256)", price));

        if (!success) {
            // checking bool return value to prevent silent failure
            revert Delegatefailed();
        }

        uint256 newPrice = abi.decode(data, (uint256));
        price = newPrice;
    }
}

contract Called {
    uint256 public discountRate = 20;

    function calculateDiscountPrice(uint256 amount) public view returns (uint256) {
        return amount - (amount * discountRate) / 100;
    }
}

contract proxySlot {
    address public Oner = address(1); // storage collision causing contract to break

    function callIncrement(address increment) external {
        (bool success,) = increment.delegatecall(abi.encodeWithSignature("increment()")); // making delegate call
        require(success, "Unsuccess"); // checking return bool
    }
}

contract incrment {
    uint256 public value; // variable to increment

    function increment() external {
        value++; // increment value
    }
}

contract Caller {
    function callUnExist(address Sans_Function) external returns (bytes memory) {
        (bool success, bytes memory data) =
            Sans_Function.call(abi.encodeWithSignature("Room(address, string memory)", address(1), "maker")); // making lower level call to a contract having fallback
        require(success, "Unsuccessful"); // checking bool
        return (data); // checking data
    }

    function call_noRoom(address Sans_Function) external returns (bytes memory) {
        (bool success, bytes memory data) = Sans_Function.call(abi.encodeWithSignature("noRoom()")); // making lower level call to the function
        require(success, "Unsuccessful"); // checking bool
        return (data); // checking data
    }
}

contract SansFunction {
    fallback(bytes calldata) external payable returns (bytes memory) {
        // triggers when receives data/no function exist
        return msg.data;
    }

    receive() external payable {} // triggers when msg.value is present

    function noRoom() external pure returns (uint256) {
        return 14;
    }
}
