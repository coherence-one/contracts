// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AddCollectionScript is Script {
    function setUp() public {}

    function run() public {
      Marketplace marketplace = Marketplace(0x00000000107eAC5C457503d70193603851da4c8a);
      vm.startBroadcast();
      // marketplace.addCollection(0xC29Ca7c72Da0873693BF2d686544C17222EC2659);
      marketplace.setMarketplaceFee(50);
      // marketplace.setCollectionFee(0x3eE3B977d6C9658fC787AD76CC42b8940c01aF20, 30, 0xB1fd9986cC04C55EaF536D9a5422c9C91F4Ad051);
      vm.stopBroadcast();
    }
}
