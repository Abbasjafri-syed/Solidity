// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {beacon_Implement} from "src/TransParent/BeaconImplement.sol";
import {ImplementBeaconV2} from "src/TransParent/ImplementV2.sol";

import {UpgradeableBeacon} from "lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "lib/openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";

contract beacon_Script is Script {
    address Owner = makeAddr("Owner"); // address of Owner
    mapping(uint256 => address) public vaults;

    beacon_Implement Implement; // logic addresss
    UpgradeableBeacon beaconProxy; // pointer to UpgradeableBeacon
    BeaconProxy proxy_Factory; // pointer to beaconProxy

    function run() external returns (UpgradeableBeacon) {
        Implement = new beacon_Implement(); // deploying logic contract
        beaconProxy = new UpgradeableBeacon(address(Implement), Owner); // deploying beacon proxy
        return beaconProxy; // returning proxy
    }

    function beaconFactory(uint256 _value, string memory _name) external returns (address) {
        bytes memory initData = abi.encodeWithSelector(Implement.initialize.selector, _value, _name); // data to be passed
        proxy_Factory = new BeaconProxy(address(beaconProxy), initData); // deploying beacon factory
        vaults[_value] = address(proxy_Factory);
        return address(proxy_Factory); // returning becon proxy
    }

    function beaconFactoryUpgrade(uint256 _value, string memory _name) external returns (address) {
        bytes memory initData = abi.encodeWithSelector(ImplementBeaconV2.initialize.selector, _value, _name); // data to be passed
        proxy_Factory = new BeaconProxy(address(beaconProxy), initData); // deploying beacon factory
        vaults[_value] = address(proxy_Factory);
        return address(proxy_Factory); // returning becon proxy
    }
}
