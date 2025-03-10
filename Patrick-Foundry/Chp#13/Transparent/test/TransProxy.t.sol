// SPDX-License-dentifier: Non-production
pragma solidity 0.8.21;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {
    TransparentUpgradeableProxy,
    ProxyAdmin,
    ITransparentUpgradeableProxy
} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {TransParentImplement} from "src/TransParent/TransImp.sol";
import {ImplementV2} from "src/TransParent/ImplementV2.sol";
import {TransParentScript} from "script/TransScript.sol";

contract TestProxy is Test {
    TransParentImplement TransLogic; // pointer to implementation
    TransparentUpgradeableProxy TransProxy; // pointer to Proxy
    TransParentScript ScriptRun; // pointer to script

    address Owner = makeAddr("Owner"); // address of Owner

    address _admin; // proxyAdmin

    function setUp() external {
        ScriptRun = new TransParentScript(); // deploying script and caching addresses
        (TransLogic, TransProxy) = ScriptRun.run();
    }

    // forge t --mt test_infoTrans -vvv
    function test_infoTrans() external {
        console.log("Implementation Contract:", address(TransLogic));
        console.log("TransParent Proxy Contract:", address(TransProxy));
    }

    // forge t --mt test_AdminProxy -vvv
    function AdminProxy() internal returns (address) {
        bytes32 ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103; // storage slot of admin for Transparent Proxy
        bytes32 data = vm.load(address(TransProxy), ADMIN_SLOT); // loading value stored at given slot of an contract address
        address proxyAdmin = address(uint160(uint256(data))); // conversion data into address
        return proxyAdmin; // Admin of proxyAdmin Contract
    }

    // forge t --mt test_generateHash -vvv
    function test_generateHash() external {
        // keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.

        bytes32 adminSlot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
        console.log("ADMIN_SLOT");
        console.logBytes32(adminSlot);

        bytes32 ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103; // storage slot of admin for Transparent Proxy
        assertEq(adminSlot, ADMIN_SLOT, "Hash Not Same");
    }

    // forge t --mt test_SetValue -vvv
    function test_SetValue() external {
        TransParentImplement ProxyContract = TransParentImplement(address(TransProxy)); // pointer to proxy
        uint256 value = ProxyContract.InitialValue(); // value saved at proxy
        console.log("InitialValue", value); // initial value
    }

    // forge t --mt test_getVersion -vvv
    function test_getVersion() external {
        TransParentImplement ProxyContract = TransParentImplement(address(TransProxy)); // pointer to proxy
        string memory Version = ProxyContract.getVersion(); // value saved at proxy
        console.log("Implement:", Version); // initial value
    }

    // forge t --mt test_secondInitialize -vvv
    function test_secondInitialize() external {
        TransParentImplement ProxyContract = TransParentImplement(address(TransProxy)); // caching proxy address
        vm.expectRevert(Initializable.InvalidInitialization.selector); // expecting revert with custom error
        ProxyContract.initialize(uint256(11014)); // calling function through proxy
    }

    // forge t --mt test_initializeImplement -vvv
    function test_initializeImplement() external {
        vm.expectRevert(Initializable.InvalidInitialization.selector); //expecting revert with custom error
        TransLogic.initialize(uint256(11014)); // calling function directly of implementation
    }

    // forge t --mt test_callUpgrade -vvv
    function test_callUpgrade() public {
        address proxy_Admin = AdminProxy(); // caching admin address
        ImplementV2 UpGradeV2 = new ImplementV2(); // deploying upgrade
        vm.prank(Owner); // call made from owner
        ProxyAdmin(proxy_Admin).upgradeAndCall( // making upgrade call
            ITransparentUpgradeableProxy(address(TransProxy)),
            address(UpGradeV2),
            abi.encodeWithSelector(ImplementV2.initialize.selector, 786110)
        );
    }

    // forge t --mt test_revertUpgrade -vvv
    function test_revertUpgrade() public {
        address proxy_Admin = AdminProxy(); // caching admin address
        address zero_Upgrade = address(0);

        vm.prank(Owner); // call made from owner
        vm.expectRevert();
        ProxyAdmin(proxy_Admin).upgradeAndCall( // making upgrade call to address(0)
            ITransparentUpgradeableProxy(address(TransProxy)),
            address(zero_Upgrade),
            abi.encodeWithSelector(ImplementV2.initialize.selector, 786110)
        );
    }

    // forge t --mt test_UpgradeVersion -vvv
    function test_UpgradeVersion() external {
        test_callUpgrade();
        ImplementV2 ProxyContract = ImplementV2(address(TransProxy));
        string memory up_Version = ProxyContract.getVersion();
        console.log("Upgrade Version", up_Version);
    }

    // forge t --mt test_getSlot -vvv
    function test_getSlot() external returns (uint256) {
        test_callUpgrade();
        ImplementV2 ProxyUpgrade = ImplementV2(address(TransProxy));
        TransParentImplement ProxyContract = TransParentImplement(address(TransProxy));

        bytes32 slotZero = vm.load(address(ProxyContract), bytes32(uint256(0)));
        emit log_uint(uint256(slotZero));

        bytes32 slotZeroUp = vm.load(address(ProxyUpgrade), bytes32(uint256(0)));
        emit log_uint(uint256(slotZero));
    }

    // forge t --mt test_getVariable -vvv
    function test_getVariable() external {
        test_callUpgrade();
        bytes memory initData = abi.encodeWithSelector(ImplementV2.valueDec.selector);
        ImplementV2 ProxyUpgrade = ImplementV2(address(TransProxy));
        address(ProxyUpgrade).call(initData);
        uint256 value = ProxyUpgrade.SecondSlot();
        console.log("Upgrade Contract Slot:", value);
    }
}
