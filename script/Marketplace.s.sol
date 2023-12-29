// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract MarketplaceDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        Marketplace marketplace = new Marketplace();
        vm.stopBroadcast();
    }
}
