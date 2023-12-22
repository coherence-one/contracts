// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    error NotOwner(uint256 tokenId);
    error NotApproved(uint256 tokenId);
    error WrongPrice(uint256 tokenId);
    event PutOnSale(address indexed collection, uint256 indexed tokenId, uint256 price);
    event Deal(address indexed collection, uint256 indexed tokenId, uint256 price);

    uint256 public fee = 50; // 5% of 1000
    mapping (address collection => mapping (uint256 tokenId => uint256 price)) private forSale;

    constructor() Ownable(msg.sender) {}

    function setToSell(address collection, uint256 tokenId, uint256 price) external {
        if (IERC721(collection).ownerOf(tokenId) != msg.sender) {
            revert NotOwner(tokenId);
        }
        if (IERC721(collection).getApproved(tokenId) != address(this)) {
            revert NotApproved(tokenId);
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
        payable(IERC721(collection).ownerOf(tokenId)).transfer(msg.value * (1000 - fee) / 1000);
        IERC721(collection).transferFrom(IERC721(collection).ownerOf(tokenId), msg.sender, tokenId);
        delete forSale[collection][tokenId];
        emit Deal(collection, tokenId, msg.value);
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }

    function withdrawERC20(address token) external onlyOwner {
        // TODO test
        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, IERC20(token).balanceOf(address(this))));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'withdraw: TRANSFER_FAILED');
    }
}
