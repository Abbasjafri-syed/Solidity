// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {implementChild} from "../src/implement.sol";
import {upgradedImplement} from "../src/UpgradeV1.sol";
import {upgradedSecondVersion} from "../src/UpgradeV2.sol";

import {childImplementScript} from "../script/implementScript.s.sol";
import {childUpgradeScript} from "../script/UpV1.s.sol";
import {UpgradeSecondScript} from "../script/UpV2.s.sol";

contract implementUpgradeTest is Test {
    childImplementScript child_Script; // pointer to childImplementScript
    childUpgradeScript upgrade_Script; // pointer to childUpgradeScript
    UpgradeSecondScript Upgrade_2ndScript; // pointer to childUpgradeScript

    address childProxy;

    function setUp() external {
        child_Script = new childImplementScript(); // deploying implement script
        childProxy = child_Script.run(); // proxy child

        upgrade_Script = new childUpgradeScript(); // deploying upgrade script
        Upgrade_2ndScript = new UpgradeSecondScript(); // deploying Upgrade_2ndScript script
    }

    //  forge t --mt test_versionSecondUp -vvv
    function test_versionSecondUp() external {
        test_secondUpgrade(); //  calling function second Upgrade
        address upgrade2ndProxy = Upgrade_2ndScript.run(childProxy); // running script and pointing proxy to new implement
        string memory Verup = upgradedSecondVersion(upgrade2ndProxy).versionChild();
        console.log("2nd Upgrade Version:", Verup);
    }

    //  forge t --mt test_secondUpgrade -vvv
    function test_secondUpgrade() public {
        // test_SetValue(); // calling function set value implement
        test_UpgradeImplement(); // calling function upgrade implement
        address upgradeProxy = upgrade_Script.run(childProxy); // running script and pointing proxy to new implement

        vm.prank(address(Upgrade_2ndScript)); // making call with script
        upgradedImplement(upgradeProxy).initializeChildUp(); // calling initializeChildUp
    }

    //  forge t --mt test_UpZeroSlot -vvv
    function test_UpZeroSlot() external {
        test_SetValue(); // calling function set value implement
        test_UpgradeImplement(); // calling function upgrade implement
        address upgradeProxy = upgrade_Script.run(childProxy); // running script and pointing proxy to new implement

        uint256 SlotZero = upgradedImplement(upgradeProxy).getValued(0);
        console.log("Slot Zero Value:", SlotZero);
    }

    //  forge t --mt test_ZeroSlot -vvv
    function test_ZeroSlot() external {
        test_SetValue(); // calling function set value implement
        test_UpgradeImplement(); // calling function upgrade implement
        address upgradeProxy = upgrade_Script.run(childProxy); // running script and pointing proxy to new implement

        uint256 SlotZero = upgradedImplement(upgradeProxy).getValued(0); // getting value at slot Zero
        console.log("Slot Zero Value:", SlotZero);
    }

    //  forge t --mt test_upgradeSlot -vvv
    function test_upgradeSlot() external {
        test_UpgradeImplement(); // calling function upgrade implement
        address upgradeProxy = upgrade_Script.run(childProxy); // running script and pointing proxy to new implement

        bool initStatus = upgradedImplement(upgradeProxy).isInitialize();
        console.log("Initialize Status:", initStatus);
    }

    //  forge t --mt test_UpgradeVersion -vvv
    function test_UpgradeVersion() external {
        test_UpgradeImplement(); // calling function upgrade implement
        address upgradeProxy = upgrade_Script.run(childProxy); // running script and pointing proxy to new implment

        string memory UpVerParent = upgradedImplement(upgradeProxy).versionParent(); // getting parent version
        string memory UpVerChild = upgradedImplement(upgradeProxy).versionChild(); // getting Child version

        console.log("ParentUp Value:", UpVerParent);
        console.log("ChildUp Value:", UpVerChild);
    }

    function test_UpgradeImplement() internal {
        vm.prank(address(upgrade_Script)); // making call with owner
        implementChild(childProxy).initializeChild(); // initializing child
    }

    // forge t --mt test_Info -vvv
    function test_Info() external view {
        console.log("childProxy:", childProxy);
        console.log("child_Script:", address(child_Script));
    }

    // forge t --mt test_versionChild -vvv
    function test_versionChild() external view {
        string memory versionC = implementChild(childProxy).versionChild(); // version of child contract
        console.log("child version:", versionC);

        string memory versionP = implementChild(childProxy).versionParent(); // version of Parent contract
        console.log("Parent version:", versionP);
    }

    // forge t --mt test_SetValue -vvv
    function test_SetValue() public {
        implementChild(childProxy).setValue(5); // setting value
        uint256 valueSet = implementChild(childProxy).getValue(); // caching value
        console.log("Parent Value:", valueSet);
    }

    // forge t --mt test_SetInitialized -vvv
    function test_SetInitialized() external {
        implementChild(childProxy).initializeChild(); // initializing child
        bool isInital = implementChild(childProxy).initializeContract();
        console.log("Contract Initialized:", isInital);

        uint256 valueSet = implementChild(childProxy).getValue(); // caching value
        console.log("Parent Value:", valueSet);

        implementChild(childProxy).setValue(5); // setting value
        valueSet = implementChild(childProxy).getValue(); // caching value
        console.log("Parent Value:", valueSet);
    }
}
