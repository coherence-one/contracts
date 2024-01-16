// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {CollectionMock} from "../src/CollectionMock.sol";

contract MarketplaceTest is Test {
    error NotOwner(uint256 tokenId); // tested
    error NotApproved(uint256 tokenId); // ???
    error WrongPrice(uint256 tokenId, uint256 price); // tested
    error CollectionNotEnumerable(); // tested
    error CollectionNotAdded(address collection); // tested
    error WrongCurrentOwner(uint256 tokenId); // tested
    error WrongCollection(); // tested
    error RoyaltyTooBig(); // tested

    event PutOnSale(address indexed collection, uint256 indexed tokenId, uint256 price); // tested
    event Deal(address indexed collection, uint256 indexed tokenId, uint256 price); // tested
    event CollectionAdded(address indexed collection); // tested
    event MarketplaceFeeChanged(uint256 newFee); // tested
    event CollectionFeeChanged(address indexed collection, uint16 newFee, address beneficiar); // tested
    error Reentrancy();

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
        vm.expectEmit(true, false, false, false);
        emit CollectionAdded(address(collection));
        marketplace.addCollection(address(collection));

        collection.approve(address(marketplace), 1);
        vm.startPrank(address(443434));
        vm.expectRevert(abi.encodeWithSelector(NotOwner.selector, 1));
        marketplace.setToSell(address(collection), 1, 1000);
    }

    function test_SellSuccess() external {
        vm.expectRevert(WrongCollection.selector);
        marketplace.setCollectionFee(address(collection), 20, address(0x3333));

        vm.expectEmit(true, false, false, false);
        emit CollectionAdded(address(collection));
        marketplace.addCollection(address(collection));

        vm.expectRevert(RoyaltyTooBig.selector);
        marketplace.setCollectionFee(address(collection), 510, address(0x3333)); // 51%
        vm.expectEmit(true, true, false, true);
        emit CollectionFeeChanged(address(collection), 20, address(0x3333));
        marketplace.setCollectionFee(address(collection), 20, address(0x3333)); // 2%

        collection.approve(address(marketplace), 1);
        vm.expectEmit(true, true, false, true);
        emit PutOnSale(address(collection), 1, 1000);
        marketplace.setToSell(address(collection), 1, 1000);
        assertTrue(marketplace.getPrice(address(collection), 1) == 1000);

        vm.startPrank(BUYER);
        vm.deal(BUYER, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(WrongPrice.selector, 1, 1000));
        marketplace.buy{value: 0.1 ether}(address(collection), 1);
        vm.expectRevert(abi.encodeWithSelector(WrongPrice.selector, 1, 1000));
        marketplace.buy{value: 0}(address(collection), 1);
        vm.expectRevert(abi.encodeWithSelector(WrongPrice.selector, 1, 1000));
        marketplace.buy{value: 5}(address(collection), 1);

        vm.expectEmit(true, true, false, true);
        emit Deal(address(collection), 1, 1000);
        marketplace.buy{value: 1000}(address(collection), 1);
        // check balances
        assertTrue(address(marketplace).balance == 50); // fee 50 = 5%
        assertTrue(address(BUYER).balance == 1 ether - 1000);
        assertTrue(address(SELLER).balance == 1000 - 50 - 20);
        assertTrue(address(0x3333).balance == 20); // collectionFee
    }

    function test_SellNotApproved() external {
        marketplace.addCollection(address(collection));

        collection.approve(address(marketplace), 1);
        marketplace.setToSell(address(collection), 1, 1000);

        collection.approve(address(0), 1);
        console2.log("collection.getApproved(1)", collection.getApproved(1));
        // console2.log("IERC721(collection).getApproved(1)", IERC721(address(collection)).getApproved(1));
        console2.log("collection", address(collection));

        // TODO!
        // vm.startPrank(BUYER);
        // vm.deal(BUYER, 1 ether);
        // vm.expectRevert(abi.encodeWithSelector(NotApproved.selector, 1));
        // marketplace.buy{value: 1000}(address(collection), 1);
    }

    function test_NotCurrentOwner() external {
        vm.expectEmit(true, false, false, false);
        emit CollectionAdded(address(collection));
        marketplace.addCollection(address(collection));

        collection.approve(address(marketplace), 1);
        marketplace.setToSell(address(collection), 1, 1000);

        collection.transferFrom(SELLER, address(34443), 1);

        vm.startPrank(BUYER);
        vm.deal(BUYER, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(WrongCurrentOwner.selector, 1));
        marketplace.buy{value: 1000}(address(collection), 1);
    }

    function test_CollectionNotEnumerable() external {
        vm.expectRevert(abi.encodeWithSelector(CollectionNotEnumerable.selector));
        marketplace.addCollection(address(this));
    }

    function test_MarketplaceFee() external {
        vm.expectEmit(true, false, false, false);
        emit CollectionAdded(address(collection));
        marketplace.addCollection(address(collection));

        vm.expectEmit(true, false, false, false);
        emit MarketplaceFeeChanged(100);
        marketplace.setMarketplaceFee(100);
        assertTrue(marketplace.marketplaceFee() == 100);
    }
}
