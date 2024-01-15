// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AddCollectionScript is Script {
    function setUp() public {}

    function run() public {
      Marketplace marketplace = Marketplace(0x8fD02Bc877410A6Ee9d927216362D1601B1843Ff);
      vm.startBroadcast();
      marketplace.addCollection(0xd88980c139f0267A0Af9eaA21DD3062f79515D74);
      vm.stopBroadcast();
    }
}
