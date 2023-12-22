// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
}

contract Marketplace {
    uint256 public fee = 50; // 5% of 1000
    error NotOwner(uint256 tokenId);
    error NotApproved(uint256 tokenId);
    error WrongPrice(uint256 tokenId);

    event PutOnSale(address indexed collection, uint256 indexed tokenId, uint256 price);

    mapping (address collection => mapping (uint256 tokenId => uint256 price)) private forSale;

    function setToSell(address collection, uint256 tokenId, uint256 price) external {
        if (IERC721(collection).ownerOf(tokenId) != msg.sender) {
            revert NotOwner(IERC721(collection).ownerOf(tokenId));
        }
        if (IERC721(collection).getApproved(tokenId) != address(this)) {
            revert NotApproved(IERC721(collection).ownerOf(tokenId));
        }
        forSale[collection][tokenId] = price;
    }

    function getPrice(address collection, uint256 tokenId) external view returns (uint256) {
        return forSale[collection][tokenId];
    }

    function buy(address collection, uint256 tokenId) external payable {
        if (msg.value != forSale[collection][tokenId]) {
            revert WrongPrice(forSale[collection][tokenId]);
        }
        payable(IERC721(collection).ownerOf(tokenId)).transfer(msg.value * (100 - fee) / 100);
        IERC721(collection).transferFrom(IERC721(collection).ownerOf(tokenId), msg.sender, tokenId);
        delete forSale[collection][tokenId];
    }

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setFee(uint256 newFee) external {
        fee = newFee;
    }
}
