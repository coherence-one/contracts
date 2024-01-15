// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {CollectionMock} from "../src/CollectionMock.sol";

contract MarketplaceTest is Test {
    error NotOwner(uint256 tokenId);
    error NotApproved(uint256 tokenId);
    error WrongPrice(uint256 tokenId);
    error CollectionNotEnumerable();
    error CollectionNotAdded(address collection);
    error WrongCurrentOwner(uint256 tokenId);
    error WrongCollection();
    error RoyaltyTooBig();

    event PutOnSale(address indexed collection, uint256 indexed tokenId, uint256 price);
    event Deal(address indexed collection, uint256 indexed tokenId, uint256 price);
    event CollectionAdded(address indexed collection);

    Marketplace public marketplace;
    CollectionMock public collection;
    address constant SELLER = address(0x1111);
    address constant BUYER = address(0x2222);

    function setUp() external {
        vm.startPrank(SELLER);
        marketplace = new Marketplace();
        marketplace.initialize();
        collection = new CollectionMock();
        collection.mint(1);
    }

    function test_CollectionNotAdded() external {
        collection.approve(address(marketplace), 1);
        vm.expectRevert(abi.encodeWithSelector(CollectionNotAdded.selector, address(collection)));
        marketplace.setToSell(address(collection), 1, 1000);
    }

    function test_SellNotOwner() external {
        marketplace.addCollection(address(collection));
        collection.approve(address(marketplace), 1);
        vm.startPrank(address(443434));
        vm.expectRevert(abi.encodeWithSelector(NotOwner.selector, 1));
        marketplace.setToSell(address(collection), 1, 1000);
    }

    function test_SellNotApproved() external {
        
    }

    function test_Sell() external {
        vm.expectEmit(true, false, false, false);
        emit CollectionAdded(address(collection));
        marketplace.addCollection(address(collection));
        collection.approve(address(marketplace), 1);
        marketplace.setToSell(address(collection), 1, 1000);
        assertTrue(marketplace.getPrice(address(collection), 1) == 1000);
        vm.startPrank(BUYER);
        vm.deal(BUYER, 1 ether);
        marketplace.buy{value: 1000}(address(collection), 1);
    }
}
