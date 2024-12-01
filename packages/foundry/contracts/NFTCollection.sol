// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage {
    uint256 private nextTokenId = 0;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function safeMint(address to, string memory tokenURI) public {
        nextTokenId++;
        _safeMint(to, nextTokenId);
        _setTokenURI(nextTokenId, tokenURI);

        emit NFTMinted(nextTokenId, to, tokenURI);
    }

    event NFTMinted(uint256 indexed tokenId, address indexed owner, string tokenURI);
}
