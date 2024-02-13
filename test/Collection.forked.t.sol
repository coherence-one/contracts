// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Marketplace} from "../src/Marketplace.sol";


contract CollectionForkedTest is Test {
  ERC721Enumerable collection = ERC721Enumerable(0x2aE38daf793fCdBA9fe704a17b38C7B1981e5Df3);
  uint256 firstTokenId;
  address constant buyer = address(1001);
  Marketplace constant marketplace = Marketplace(0x00000000107eAC5C457503d70193603851da4c8a);

  function setUp() external {
    vm.createSelectFork("https://a.api.s0.t.hmny.io");
    vm.deal(buyer, 100 ether);
  }

  function test_Approve() external {
    firstTokenId = collection.tokenByIndex(0);
    console2.log("First token", firstTokenId);
    address firstTokenOwner = collection.ownerOf(firstTokenId);
    console2.log("First token owner", firstTokenOwner);

    vm.startPrank(firstTokenOwner);
    collection.setApprovalForAll(address(marketplace), true);
    marketplace.setToSell(address(collection), firstTokenId, 100);

    vm.stopPrank();
    vm.startPrank(buyer);
    marketplace.buy{value: 100}(address(collection), firstTokenId);
  }
}
