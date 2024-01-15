// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeMarketplaceScript is Script {
    function setUp() public {}

    function run() public {
      // TODO change to PA
        vm.startBroadcast();
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(payable(0x8fD02Bc877410A6Ee9d927216362D1601B1843Ff));
        Marketplace logic = new Marketplace();
        proxy.upgradeToAndCall(address(logic), bytes(""));
        vm.stopBroadcast();
    }
}
