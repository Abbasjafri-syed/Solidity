// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {TransParentImplement} from "src/TransParent/TransImp.sol";

import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TransParentScript is Script {
    address Owner = makeAddr("Owner"); // address of Owner

    TransParentImplement TransLogic; // Logic Contract
    TransparentUpgradeableProxy TransProxy; // Proxy Contract

    function run() external returns (TransParentImplement, TransparentUpgradeableProxy) {
        TransLogic = new TransParentImplement(); // deploying contract
        bytes memory initData = abi.encodeWithSelector(TransParentImplement.initialize.selector, uint256(11014));
        TransProxy = new TransparentUpgradeableProxy(address(TransLogic), Owner, initData); // deploying transparent proxy
        return (TransLogic, TransProxy);
    }
}
