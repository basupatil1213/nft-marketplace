// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace {
    struct Listing {
        address seller;
        uint256 price;
    }

    struct Auction {
        address highestBidder;
        uint256 highestBid;
        uint256 endTime;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => mapping(uint256 => Auction)) public auctions;

    uint256 public marketplaceFeePercent = 2;
    address public feeCollector;

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
    }

    // List an NFT for sale
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(nft.isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");

        listings[nftContract][tokenId] = Listing({seller: msg.sender, price: price});

        emit NFTListed(nftContract, tokenId, price, msg.sender);
    }

    // Buy an NFT
    function buyNFT(address nftContract, uint256 tokenId) public payable {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.seller != address(0), "NFT not listed");
        require(msg.value == listing.price, "Incorrect payment");

        uint256 fee = (msg.value * marketplaceFeePercent) / 100;
        uint256 sellerProceeds = msg.value - fee;

        // Transfer payment
        payable(feeCollector).transfer(fee);
        payable(listing.seller).transfer(sellerProceeds);

        // Transfer NFT
        IERC721(nftContract).safeTransferFrom(listing.seller, msg.sender, tokenId);

        delete listings[nftContract][tokenId];

        emit NFTSold(nftContract, tokenId, msg.sender, listing.price);
    }

    // Start an auction for an NFT
    function startAuction(
        address nftContract,
        uint256 tokenId,
        uint256 duration
    ) public {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(nft.isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");

        auctions[nftContract][tokenId] = Auction({
            highestBidder: address(0),
            highestBid: 0,
            endTime: block.timestamp + duration,
            active: true
        });

        emit NFTAuctionStarted(nftContract, tokenId, block.timestamp + duration);
    }

    // Place a bid on an auctioned NFT
    function placeBid(address nftContract, uint256 tokenId) public payable {
        Auction storage auction = auctions[nftContract][tokenId];
        require(auction.active, "Auction not active");
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.value > auction.highestBid, "Bid too low");

        if (auction.highestBid > 0) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        emit NFTBidPlaced(nftContract, tokenId, msg.sender, msg.value);
    }

    // Finalize an auction
    function finalizeAuction(address nftContract, uint256 tokenId) public {
        Auction memory auction = auctions[nftContract][tokenId];
        require(auction.active, "Auction already finalized");
        require(block.timestamp >= auction.endTime, "Auction not ended");

        auctions[nftContract][tokenId].active = false;

        if (auction.highestBid > 0) {
            IERC721(nftContract).safeTransferFrom(IERC721(nftContract).ownerOf(tokenId), auction.highestBidder, tokenId);
            payable(IERC721(nftContract).ownerOf(tokenId)).transfer(auction.highestBid);
        }

        emit NFTAuctionFinalized(nftContract, tokenId, auction.highestBidder, auction.highestBid);
    }

    event NFTListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTSold(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event NFTAuctionStarted(address indexed nftContract, uint256 indexed tokenId, uint256 endTime);
    event NFTBidPlaced(address indexed nftContract, uint256 indexed tokenId, address indexed bidder, uint256 bidAmount);
    event NFTAuctionFinalized(address indexed nftContract, uint256 indexed tokenId, address indexed winner, uint256 winningBid);
}
