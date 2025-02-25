// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {
    CallDelegateProxy,
    CallSimple,
    SimpleCalled,
    CallerProxy,
    CalledFirst,
    CalledLast,
    Callerslot,
    Called,
    Caller,
    SansFunction,
    proxySlot,
    incrment
} from "../src/implement.sol";

contract implementUpgradeTest is Test {
    Caller Call; // pointer to Caller
    SansFunction callback; // pointer to SansFunction
    incrment MakeIncrement; // pointer to incrment
    proxySlot callProxy; // pointer to proxySlot
    Callerslot call_Slot; // pointer to Callerslot
    Called call_Discount; // pointer to Called
    CalledLast ImplementLast; //  pointer to CalledLast
    CalledFirst proxyCalled; //  pointer to CalledLast
    CallerProxy proxyCaller; //  pointer to CalledFirst
    CallDelegateProxy proxyDelegate; //  pointer to CallDelegateProxy
    CallSimple SimplyCalled; //  pointer to CallSimple
    SimpleCalled Callee; //  pointer to SimpleCalled

    function setUp() external {
        Call = new Caller(); // deploying contract
        callback = new SansFunction();
        MakeIncrement = new incrment();
        callProxy = new proxySlot();
        call_Slot = new Callerslot();
        call_Discount = new Called();
        ImplementLast = new CalledLast();
        proxyCalled = new CalledFirst();
        proxyCaller = new CallerProxy();
        proxyDelegate = new CallDelegateProxy();
        SimplyCalled = new CallSimple();
        Callee = new SimpleCalled();
    }

    // forge t --mt test_Info -vvv
    function test_Info() external view {
        console.log("Caller:", address(Call));
        console.log("SansFunction:", address(callback));
        console.log("incrment:", address(MakeIncrement));
        console.log("proxySlot:", address(callProxy));
        console.log("Callerslot:", address(call_Slot));
        console.log("Called:", address(call_Discount));
        console.log("CalledLast:", address(ImplementLast));
        console.log("CalledFirst:", address(proxyCalled));
        console.log("CallerProxy:", address(proxyCaller));
        console.log("CallDelegateProxy:", address(proxyDelegate));
        console.log("CallSimple:", address(SimplyCalled));
        console.log("SimpleCalled:", address(Callee));
    }

    // forge t --mt test_called_nd_delegate -vvv
    function test_called_nd_delegate() external {
        console.log("address(this):", address(this));
        console.log("CallDelegateProxy:", address(proxyDelegate));

        vm.recordLogs(); // syntax for logging all events

        proxyDelegate.delegateCallToFirst(address(SimplyCalled), address(Callee)); // calling function having delegatecall in it

        Vm.Log[] memory event_Entries = vm.getRecordedLogs(); // method to access logs
        console.log("Event Generated:", event_Entries.length); // logging events generated

        bytes32 CalledFirst_Call = event_Entries[0].topics[1]; // getting 1st event generated
        bytes32 CalledLast_Call = event_Entries[1].topics[1]; // getting 2nd event

        address CalledFirst = address(uint160(uint256(CalledFirst_Call))); // event emits address so converting bytes into address
        address CalledLast = address(uint160(uint256(CalledLast_Call)));

        console.log("CalledFirst:", CalledFirst);
        console.log("CalledLast:", CalledLast);

        // assertEq(event_Entries[0].topics[0], keccak256("SenderAtCalledFirst(address)"));
    }
    // forge t --mt test_callDelegates -vvv

    function test_callDelegates() external {
        console.log("address(this):", address(this));

        vm.recordLogs(); // syntax for logging all events

        proxyCaller.delegateCallToFirst(address(proxyCalled), address(ImplementLast)); // calling function having delegatecall in it

        Vm.Log[] memory event_Entries = vm.getRecordedLogs(); // method to access logs
        console.log("Event Generated:", event_Entries.length); // logging events generated

        bytes32 CalledFirst_Call = event_Entries[0].topics[1]; // getting 1st event generated
        bytes32 CalledLast_Call = event_Entries[1].topics[1]; // getting 2nd event

        address CalledFirst = address(uint160(uint256(CalledFirst_Call))); // event emits address so converting bytes into address
        address CalledLast = address(uint160(uint256(CalledLast_Call)));

        console.log("CalledFirst:", CalledFirst);
        console.log("CalledLast:", CalledLast);

        assertEq(event_Entries[0].topics[0], keccak256("SenderAtCalledFirst(address)"));
    }

    // forge t --mt test_setDiscount -vvv
    function test_setDiscount() external {
        vm.expectRevert(); // expecting revert
        call_Slot.setDiscount(address(call_Discount)); // calling function
    }

    // forge t --mt test_calculateDiscount -vvv
    function test_calculateDiscount() external {
        uint256 Discount = call_Discount.calculateDiscountPrice(10); // calling function and passing param
        console.log("Discount Value:", Discount);
    }

    // forge t --mt test_proxyIncrement -vvv
    function test_proxyIncrement() external {
        callProxy.callIncrement(address(MakeIncrement)); // calling function
        // console.logBytes(data); // logging return data

        address oncer_Addr = callProxy.Oner(); // caching value
        console.log("Address Oner:", oncer_Addr);
    }

    // forge t --mt test_increment -vvv
    function test_increment() external {
        MakeIncrement.increment(); // calling function
        uint256 incr_Value = MakeIncrement.value(); // caching value
        console.log("Increment Value:", incr_Value);
    }

    // forge t --mt test_callNoFunction -vvv
    function test_callNoFunction() external {
        bytes memory data = Call.callUnExist(address(callback)); // calling contract
        console.logBytes(data); // logging return data
    }

    // forge t --mt test_callFunction -vvv
    function test_callFunction() external {
        bytes memory data = Call.call_noRoom(address(callback)); // calling contract
        console.logBytes(data); // calling
    }
}
