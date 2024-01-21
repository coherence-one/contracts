// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // ProxyAdmin proxyAdmin = new ProxyAdmin(msg.sender);
        // Marketplace logic = new Marketplace();
        // new TransparentUpgradeableProxy(
        //     address(logic),
        //     address(proxyAdmin),
        //     abi.encodeWithSignature("initialize()")
        // );
        // leave upgradeable proxy for Address Market
        Marketplace(0x00000000107eAC5C457503d70193603851da4c8a).initialize();
        vm.stopBroadcast();
    }
}
