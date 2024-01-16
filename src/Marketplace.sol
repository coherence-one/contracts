// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import {console2} from "forge-std/Test.sol";

contract Marketplace is OwnableUpgradeable {
    error NotOwner(uint256 tokenId);
    error NotApproved(uint256 tokenId);
    error WrongPrice(uint256 tokenId, uint256 price);
    error CollectionNotEnumerable();
    error CollectionNotAdded(address collection);
    error WrongCurrentOwner(uint256 tokenId);
    error WrongCollection();
    error RoyaltyTooBig();

    event PutOnSale(address indexed collection, uint256 indexed tokenId, uint256 price);
    event Deal(address indexed collection, uint256 indexed tokenId, uint256 price);
    event CollectionAdded(address indexed collection);
    event MarketplaceFeeChanged(uint256 newFee);
    event CollectionFeeChanged(address indexed collection, uint16 newFee, address beneficiar);
    error Reentrancy();

    struct Royalty {
        address beneficiar;
        uint16 fee;
    }

    uint256 public marketplaceFee = 50; // 5% of 1000
    mapping (address collection => mapping (uint256 tokenId => uint256 price)) private forSale;
    mapping (address collection => uint256 exists) private collectionSet;

    mapping (address collection => mapping (uint256 tokenId => address seller)) private whoSells;
    mapping (address collection => Royalty) public royalty;


    bytes4 private constant INTERFACE_ID_ERC721_ENUMERABLE = type(IERC721Enumerable).interfaceId;

    uint256 reentrancyLock;

    uint256[47] __gap;

    constructor() {}

    function initialize() external initializer() {
        __Ownable_init(msg.sender);
    }

    function setToSell(address collection, uint256 tokenId, uint256 price) external {
        if (collectionSet[collection] == 0) {
            revert CollectionNotAdded(collection);
        }
        if (IERC721(collection).ownerOf(tokenId) != msg.sender) {
            revert NotOwner(tokenId);
        }
        // console2.log("tokenId", tokenId);
        // console2.log("approved", IERC721(collection).getApproved(tokenId));
        // console2.log("isApprovedForAll", IERC721(collection).isApprovedForAll(msg.sender, address(this)));
        // console2.log("collection", collection);
        if (
            IERC721(collection).getApproved(tokenId) != address(this)
            && !IERC721(collection).isApprovedForAll(msg.sender, address(this))
            && price != 0 // to delist no need in approve
        ) {
            revert NotApproved(tokenId);
        }
        forSale[collection][tokenId] = price;
        whoSells[collection][tokenId] = price == 0 ? address(0) : msg.sender;
        emit PutOnSale(collection, tokenId, price);
    }

    function addCollection(address collection) external {
        try
            IERC165(collection).supportsInterface(INTERFACE_ID_ERC721_ENUMERABLE)
        returns (bool isEnumerable) {
            if (!isEnumerable) {
                revert CollectionNotEnumerable();
            }
        }
        catch {
            revert CollectionNotEnumerable();
        }
        collectionSet[collection] = 1;
        emit CollectionAdded(collection);
    }

    function getPrice(address collection, uint256 tokenId) external view returns (uint256) {
        return forSale[collection][tokenId];
    }

    function buy(address collection, uint256 tokenId) external payable {
        if (reentrancyLock == 0) {
            reentrancyLock = 1;
        } else {
            revert Reentrancy();
        }
        if (msg.value == 0 || msg.value != forSale[collection][tokenId]) {
            revert WrongPrice(tokenId, forSale[collection][tokenId]);
        }
        address currentOwner = IERC721(collection).ownerOf(tokenId);
        if (currentOwner != whoSells[collection][tokenId]) {
            revert WrongCurrentOwner(tokenId);
        }
        Royalty memory _royalty = royalty[collection];
        uint256 royaltyFee = _royalty.fee * msg.value / 1000;
        if (royaltyFee > 0) {
            payable(_royalty.beneficiar).transfer(royaltyFee);
        }
        delete forSale[collection][tokenId];
        IERC721(collection).transferFrom(IERC721(collection).ownerOf(tokenId), msg.sender, tokenId);
        payable(currentOwner).transfer(msg.value * (1000 - marketplaceFee) / 1000 - royaltyFee);
        emit Deal(collection, tokenId, msg.value);
        reentrancyLock = 0;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setMarketplaceFee(uint256 newFee) external onlyOwner {
        marketplaceFee = newFee;
        emit MarketplaceFeeChanged(newFee);
    }

    function setCollectionFee(address collection, uint16 newFee, address beneficiar) external onlyOwner {
        if (collectionSet[collection] == 0) {
            revert WrongCollection();
        }
        if (newFee > 100) {
            revert RoyaltyTooBig();
        }
        royalty[collection] = Royalty(beneficiar, newFee);
        emit CollectionFeeChanged(collection, newFee, beneficiar);
    }

    function withdrawERC20(address token) external onlyOwner {
        // TODO test
        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, IERC20(token).balanceOf(address(this))));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'withdraw: TRANSFER_FAILED');
    }
}
