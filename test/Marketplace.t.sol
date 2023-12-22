// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {CollectionMock} from "../src/CollectionMock.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    CollectionMock public collection;
    address constant SELLER = address(0x1111);
    address constant BUYER = address(0x2222);

    function setUp() public {
        vm.startPrank(SELLER);
        marketplace = new Marketplace();
        collection = new CollectionMock();
        collection.mint(1);
    }

    function test_Sell() public {
        collection.approve(address(marketplace), 1);
        marketplace.setToSell(address(collection), 1, 1000);
        assertTrue(marketplace.getPrice(address(collection), 1) == 1000);
        vm.startPrank(BUYER);
        vm.deal(BUYER, 1 ether);
        marketplace.buy{value: 1000}(address(collection), 1);
    }
}
