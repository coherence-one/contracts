// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract UpgradeMarketplaceScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        ProxyAdmin admin = ProxyAdmin(0x3632A01Be43329FaF79A5F9360dcBD8238381679);
        Marketplace logic = new Marketplace();
        admin.upgradeAndCall(
          ITransparentUpgradeableProxy(0x8fD02Bc877410A6Ee9d927216362D1601B1843Ff),
          address(logic),
          ""
        );
        vm.stopBroadcast();
    }
}
