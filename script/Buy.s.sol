// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BuyScript is Script {
    function setUp() public {}

    function run() public {
      IERC721 collection = IERC721(0x0bC0cdFDd36fc411C83221A348230Da5D3DfA89e);
      Marketplace marketplace = Marketplace(0x48CBF95689F7B2769f18eE397BB950d9CE69599D);
      vm.startBroadcast();
      marketplace.buy{ value: 1 ether }(address(collection), 1423);
      vm.stopBroadcast();
    }
}
