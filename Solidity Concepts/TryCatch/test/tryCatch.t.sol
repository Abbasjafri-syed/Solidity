// SPDX-License-Identifier: None

pragma solidity ^0.8.19;

import {console, Test} from "forge-std/Test.sol";
import {A} from "../src/TryCatch.sol";

contract try_Test is Test {
    A contractA;

    function setUp() external {
        contractA = new A();
    }

    // forge t --mt test_contractCheck -vvv
    function test_contractCheck() external view {
        try contractA.ext_code_size() {
            // Expected value returned by function call
        } catch (bytes memory errorCode) {
            // no error will be caught as compiler check fail for extcodesize
            console.logBytes(errorCode); // no error will be catched
        }
    }

    // forge t --mt test_Expected -vvv
    function test_Expected() external {
        try contractA.r_Expected() {
            // Expected value returned by function call
        } catch (bytes memory errorCode) {
            // no error will be caught as no return any data
            console.logBytes(errorCode); // unreachable code as called function does not return any data
        }
    }

    // forge t --mt test_Try_Expected -vvv
    function test_Try_Expected() external view {
        try contractA.try_Expected() {
            revert(); // revert the whole txn
        } catch (bytes memory errorCode) {
            // unreachable code
            console.logBytes(errorCode); // error will not be caught
        }
    }

    // forge t --mt test_contractAddress -vvv
    function test_contractAddress() external view {
        console.log("contract A:", address(contractA));
    }

    // forge t --mt test_RevertState -vvv
    function test_RevertState() external view {
        try contractA.requireState() {
            //         Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // txn will revert as error type is different
            console.log("Panic code Error: ", errorCode); // error return is of revert String
        }
    }

    error valueError(uint256 value);

    // forge t --mt test_assertFalse -vvv
    function test_assertFalse() external view {
        try contractA.falseAssert() {
            //         Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // txn will revert as catch cannot have revert
            // vm.expectRevert(abi.encodeWithSignature('valueError(uint256)', errorCode));
            // revert(); // no error caught
            revert valueError(errorCode); // custom error caught error but will revert
        }
    }

    // forge t --mt test_bytes_Return -vvv
    function test_bytes_Return() external {
        (, bytes memory err) = address(contractA).call(abi.encodeWithSignature("bytes_Return()"));
        console.log("bytes_Return length:", err.length);
        // console.logBytes(err);
    }

    // forge t --mt test_Try_requireCustomstring -vvv
    function test_Try_requireCustomstring() external view {
        try contractA.requireCustomstring() {
            //         Handle the success case if needed
            // } catch {}
            // calling function with empty custom error in require
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }
            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData); // logged here
            }
        }
    }

    // forge t --mt test_Try_addr_requireCustomaddr -vvv
    function test_Try_addr_requireCustomaddr() external view {
        try contractA.addr_requireCustomaddr() { // calling function with empty custom error in require
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            //
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsSender(address)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.log(address(this));
                console.logBytes(lowLevelData); // logged here
            }
        }
    }

    // forge t --mt test_Try_bool_requireCustom -vvv
    function test_Try_bool_requireCustom() external view {
        try contractA.bool_requireCustom() { // calling function with empty custom error in require
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            //
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsBool(bool)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData); // logged here
            }
        }
    }

    // forge t --mt test_Try_requireCustomEmpty -vvv
    function test_Try_requireCustomEmpty() external view {
        try contractA.requireCustomEmpty() { // calling function with empty custom error in require
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            //
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("emptyError()")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData); // logged here
            }
        }
    }
    // forge t --mt test_Try_falseAssert -vvv

    function test_Try_falseAssert() external view {
        try contractA.falseAssert() { // calling function with assertion
                // Handle the success case if needed
                // } catch {}
        } catch Panic(uint256 errorCode) {
            //  will be catched here
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode); // logged here
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData);
            }
        }
    }

    // forge t --mt test_Try_outOfGas -vvv
    function test_Try_outOfGas() external view {
        try contractA.outOfGas{gas: 300}() { // calling function with limited gas
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            //  will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message"); // logged here
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData);
            }
        }
    }

    // forge t --mt test_Try_dvdByZero -vvv
    function test_Try_dvdByZero() external view {
        try contractA.dvdByZero() { // calling function having divided by zero
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            //  will be catched here
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode); // logged here
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData);
            }
        }
    }
    // forge t --mt test_Try_arrUnbound -vvv

    function test_Try_arrUnbound() external view {
        try contractA.arrUnbound() { // calling function having no element in array
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            //  will be catched here
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode); // logged here
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData);
            }
        }
    }

    // forge t --mt test_Try_customErrorCheck -vvv
    function test_Try_customErrorCheck() external view {
        try contractA.customErrorCheck() { // calling function having string custom error
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("errorArgsString(string)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData); // logged here
            }
        }
    }

    // forge t --mt test_Try_emptyErrorCheck -vvv
    function test_Try_emptyErrorCheck() external view {
        try contractA.emptyErrorCheck() { // calling function having empty custom error
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            // catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("emptyError()")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes(lowLevelData); // logged here
            }
        }
    }

    // forge t --mt test_Try_requireState -vvv
    function test_Try_requireState() external view {
        try contractA.requireState() { // calling function having require with string
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason); // will be catched here
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("CustomError(param)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes4(data_Error);
            }
        }
    }

    // forge t --mt test_Try_emptyRequire -vvv
    function test_Try_emptyRequire() external view {
        try contractA.emptyRequire() { // calling function having empty require
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            //  will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message"); //  logged here
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("CustomError(param)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes4(data_Error);
            }
        }
    }

    // forge t --mt test_Try_revertString -vvv
    function test_Try_revertString() external view {
        try contractA.revertString() { // calling function having string revert
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            //  will be catched here
            // handle revert with a reason
            console.log("String Reason Error: ", reason); //  logged here
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message");
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("CustomError(param)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes4(data_Error);
            }
        }
    }

    // forge t --mt test_Try_emptyRevert -vvv
    function test_Try_emptyRevert() external view {
        try contractA.emptyRevert() { // calling function having empty revert
                // Handle the success case if needed
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("Panic code Error: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("String Reason Error: ", reason);
        } catch (bytes memory lowLevelData) {
            //  will be catched here
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("Revert Error Without Message"); //  will be logged here
            }

            // Decode the error data to check if it's the custom error
            bytes4 data_Error = bytes4(abi.encodeWithSignature("CustomError(param)")); // caching error code
            if (data_Error == bytes4(lowLevelData)) {
                // handle custom error
                console.log("Custom Error:");
                console.logBytes4(data_Error);
            }
        }
    }

    // error errorArgsString(string maker);
    //     // forge t --mt test_outOfGas -vvv
    //     function test_outOfGas() external {
    //         require(msg.sender == address(1), errorArgsString("revertStringmaker"));
    //     }

    // forge t --mt test_outOfGas -vvv
    function test_outOfGas() external {
        // vm.prank(address(1)); // true doe not return any data
        (, bytes memory data) = address(contractA).call{gas: 337}(abi.encodeWithSignature("outOfGas()"));
        console.logBytes(data); //  OOG
    }

    function customRevertWithAssembly() external pure {
        bytes32 selector = bytes32(abi.encodeWithSignature("Unauthorized()"));

        assembly {
            mstore(0x00, selector) //- Store the function selector for the custom error

            revert(0x00, 0x04)
        }
    }

    // forge t --mt test_dvdByZero -vvv
    function test_dvdByZero() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("dvdByZero()"));
        console.logBytes(data); //  return data 1st 4 bytes of function selector of assert error 'Panic(uint256)' and error code
    }

    // forge t --mt test_ArrayEmpty -vvv
    function test_ArrayEmpty() external {
        (, bytes memory data) = address(contractA).call{gas: 4000}(abi.encodeWithSignature("arrUnbound()"));
        console.logBytes(data); //  return data  1st 4 bytes of function selector of assert error 'Panic(uint256)' and error code
    }

    // forge t --mt test_Assertfalse -vvv
    function test_Assertfalse() external {
        // vm.prank(address(1)); // true doe not return any data
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("falseAssert()"));
        console.logBytes(data); //  return data  1st 4 bytes of function selector of assert error 'Panic(uint256)' and error code
    }

    // forge t --mt test_stringrequireCustom -vvv
    function test_stringrequireCustom() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("requireCustomstring()"));
        console.logBytes(data); //  return data  1st 4 bytes of custom error function selector and rest will be abiencoding
    }

    // forge t --mt test_addrrequireCustom -vvv
    function test_addrrequireCustom() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("addr_requireCustomaddr()"));
        console.logBytes(data); //  return data  1st 4 bytes of custom error function selector
        console.log("contract:", address(this));
    }

    // forge t --mt test_requireCustomEmpty -vvv
    function test_requireCustomEmpty() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("requireCustomEmpty()"));
        console.logBytes(data); //  return data  1st 4 bytes of custom error function selector
    }

    // forge t --mt test_emptyRequire -vvv
    function test_emptyRequire() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("emptyRequire()"));
        console.logBytes(data); // return empty data '0x' similar to empty revert
    }

    // forge t --mt test_requireState -vvv
    function test_requireState() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSelector(contractA.requireState.selector)); // caching return data
        console.logBytes(data); //  require with statement return similar data like revert with string
    }

    // forge t --mt test_emptyRevert -vvv
    function test_emptyRevert() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("emptyRevert()")); // caching return data
        console.logBytes(data); // 0x
    }

    // forge t --mt test_StringRevert -vvv
    function test_StringRevert() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("revertString()")); // caching return data
        console.logBytes(data); // return data of revert with string
            //  0x08c379a <-- function selector
            //  0000000000000000000000000000000000000000000000000000000000000002 <-- location offset
            //  00000000000000000000000000000000000000000000000000000000000000011 <-- string length
            // 726576657274537472696e676d616b6572000000000000000000000000000000 <-- string in hex
    }

    // forge t --mt test_customNoArgs -vvv
    function test_customNoArgs() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSelector(contractA.emptyErrorCheck.selector)); // caching return data
        console.logBytes(data); // return data will be function selector of custom error
    }
    // forge t --mt test_customWithArgs -vvv

    function test_customWithArgs() external {
        (, bytes memory data) = address(contractA).call(abi.encodeWithSignature("customErrorCheck()")); // caching return data
        console.logBytes(data); // return data will be function selector of custom error
        console.log("sender", address(this));
    }

    // forge t --mt test_bytesLength -vvv
    function test_bytesLength() external view {
        // bytes memory lengther = abi.encode('revertStringmaker');
        console.logBytes(bytes("revertStringmaker")); // 0x
    }

    // forge t --mt test_max -vvv
    function test_max() external view {
        uint256 max = type(uint256).max;
        console.log("max", max); //
    }
}
