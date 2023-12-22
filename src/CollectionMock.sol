// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract CollectionMock is ERC721 {
  constructor() ERC721("CollectionMock", "CM") {}

  function mint(uint256 tokenId) external {
    _mint(msg.sender, tokenId);
  }
}
