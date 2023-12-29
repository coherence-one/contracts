// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {CollectionMock} from "../src/CollectionMock.sol";

// 1) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
// 2) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
// 3) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
/*
forge script AnvilBuyScript --rpc-url http://127.0.0.1:8545 --private-key 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a --broadcast
*/
contract AnvilBuyScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        CollectionMock collectionMock = CollectionMock(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        Marketplace marketplace = Marketplace(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);

        marketplace.buy{ value: 1 ether }(address(collectionMock), 444);
        vm.stopBroadcast();
    }
}
