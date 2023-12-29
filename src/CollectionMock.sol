// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract CollectionMock is ERC721Enumerable {
  constructor() ERC721("CollectionMock", "CM") {}

  function mint(uint256 tokenId) external {
    _mint(msg.sender, tokenId);
  }
}
