// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {beacon_Implement} from "src/TransParent/BeaconImplement.sol";
import {ImplementBeaconV2} from "src/TransParent/ImplementV2.sol";

import {beacon_Script} from "script/BeaconScript.sol";

import {UpgradeableBeacon} from "lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "lib/openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";

contract TestProxy is Test {
    address Owner = makeAddr("Owner"); // address of Owner

    beacon_Script Script_Beacon; //pointer to beacon_Script

    UpgradeableBeacon beaconProxy; // pointer to UpgradeableBeacon
    BeaconProxy proxy_Factory; // pointer to beaconProxy

    function setUp() external {
        Script_Beacon = new beacon_Script(); // decploying script
        beaconProxy = Script_Beacon.run(); //caching beacon proxy
    }

    // forge t --mt test_infoTrans -vvv
    function test_infoTrans() external {
        console.log("Upgradeable Beacon address:", address(beaconProxy));
    }

    // forge t --mt test_getImplementation -vvv
    function test_getImplementation() external {
        address implement = beaconProxy.implementation(); // implementation address
        console.log("Implementation address:", implement);
    }

    // forge t --mt test_createBeacon -vvv
    function createBeacon() internal returns (address) {
        address beacon1 = Script_Beacon.beaconFactory(uint256(1), "Vault-1");
        // console.log("Beacon address:", beacon1);
        return beacon1;
    }

    // forge t --mt test_Vaultimplement -vvv
    function test_Vaultimplement() external {
        address beacon1 = createBeacon();
        uint256 getVault = beacon_Implement(beacon1).vault_Number();
        console.log("Vault Id:", getVault);
    }
    // forge t --mt test_vaultName -vvv

    function test_vaultName() external {
        address beacon1 = createBeacon();
        string memory name_Vault = beacon_Implement(beacon1).vault_Name();
        console.log("Vault Name:", name_Vault);
    }

    // forge t --mt test_getVersion -vvv
    function test_getVersion() external {
        address beacon1 = createBeacon();
        string memory Version = beacon_Implement(beacon1).getVersion();
        console.log("Vault Id:", Version);
    }

    // forge t --mt test_SecondBeacon -vvv
    function test_SecondBeacon() external {
        address beacon1 = createBeacon();
        address beacon2 = Script_Beacon.beaconFactory(uint256(2), "Vault-2"); // cretaing second beacon

        address beaconVault1 = Script_Beacon.vaults(1); // getting beacon address
        address beaconVault2 = Script_Beacon.vaults(2);

        assertEq(beacon1, beaconVault1, "Address not Matched"); // matching addresses
        assertEq(beacon2, beaconVault2, "Address not Matched");
    }

    // forge t --mt test_ZeroSlot -vvv
    function test_ZeroSlot() external {
        address beacon1 = createBeacon();

        bytes32 data = vm.load(beacon1, 0);
        uint256 vaultNumber = uint256(data);

        // console.log("Vault Number:", vaultNumber);
        uint256 value_Vault = beacon_Implement(beacon1).vault_Number();
        assertEq(vaultNumber, value_Vault, "Value at Slot 0"); // matching addresses
    }

    // forge t --mt test_1stSlot -vvv
    function test_1stSlot() external {
        address beacon1 = createBeacon();

        bytes32 uintData = vm.load(beacon1, bytes32(uint256(1)));
        string memory name_Vault = beacon_Implement(beacon1).vault_Name();

        console.logBytes32(uintData);
    }

    // forge t --mt test_doubleInit -vvv
    function test_doubleInit() external {
        address beacon1 = createBeacon();
        vm.expectRevert(); // expect revert on initialization
        beacon_Implement(beacon1).initialize(uint256(56), "Vault2"); // calling initialize function again
    }

    // forge t --mt test_Implement_doubleInit -vvv
    function test_Implement_doubleInit() external {
        beacon_Implement Implement = new beacon_Implement();
        Implement.initialize(uint256(56), "Vault2"); // calling initialize function directly on implement
    }

    // forge t --mt beaconUpgradeImplement -vvv
    function beaconUpgradeImplement() internal returns (address) {
        address implement = beaconProxy.implementation(); // implementation address
        // console.log("Implementation address:", implement);

        ImplementBeaconV2 Second_Implement = new ImplementBeaconV2(); // deploying upgrade function

        vm.prank(Owner); // initiating call with owner
        beaconProxy.upgradeTo(address(Second_Implement)); // upgrading Implement address
        address up_beacon1 = Script_Beacon.beaconFactoryUpgrade(uint256(12), "VaultUp-1"); // deploying new proxy to new implement
        return up_beacon1;
    }

    // forge t --mt test_UpGradeInfo -vvv
    function test_UpGradeInfo() external {
        address up_beacon1 = beaconUpgradeImplement(); // upgrading implement
        string memory UpgradeVersion = ImplementBeaconV2(up_beacon1).getVersion(); // getting version
        console.log("Upgrade Version:", UpgradeVersion);

        uint256 UpgradeVaultNum = ImplementBeaconV2(up_beacon1).vaultUp_Number(); // getting Vault Number
        console.log("Upgrade Vault Num:", UpgradeVaultNum);

        string memory UpgradeVaultName = ImplementBeaconV2(up_beacon1).vaultUp_Name(); // getting version
        console.log("Upgrade Vault Name:", UpgradeVaultName);
    }

    // forge t --mt test_decreUpGradeInfo -vvv
    function test_decreUpGradeInfo() external {
        address up_beacon1 = beaconUpgradeImplement(); // upgrading implement

        uint256 UpgradeVaultNum = ImplementBeaconV2(up_beacon1).vaultUp_Number(); // getting Vault Number
        console.log("Upgrade Vault Num:", UpgradeVaultNum);

        for (uint256 i; i < UpgradeVaultNum; ++i) { // running loop till 0
        ImplementBeaconV2(up_beacon1).valueDec(); // getting Vault Number
        }

        UpgradeVaultNum = ImplementBeaconV2(up_beacon1).vaultUp_Number(); // getting Vault Number
        console.log("Upgrade Vault Num:", UpgradeVaultNum);
    }
}
