// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // This will allow us to protect against reentarcy attacks
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner; // The payable modifier is one of the things that makes solidity so cool! This will allow us to reciever ether.
  uint256 listingPrice = 0.025 ether;

  constructor() {
    owner = payable(msg.sender); // The owner of this contract is the deployer
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;

    // The indexed keyword helps you to filter the logs to find the wanted data. thus you can search for specific items instead getting all the logs. in general
    // Events are used to inform external users that something happened on the blockchain                          
  event MarketItemCreated ( 
    uint indexed itemId, 
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  // Returns the listing price of the contract 
  // view modifiers do not write to blockchain. The only query your local node. Therefore they do not require any gas
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }
  
  // Places an item for sale on the marketplace 
  function createMarketItem(
    address nftContract,
    uint256 tokenId, // comes from the NFT Contract
    uint256 price // The end user defnes the price
  ) public payable nonReentrant { // The "nonReentrant" modifier helps prevent rentrancy attacks. You can read more about reentrancy attacks here: https://www.youtube.com/watch?v=4Mm3BCyHtDY
    require(price > 0, "Price must be at least one wei");
    require(msg.value == listingPrice, "Price must be equel to the listing price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)), // The seller is putting this for sale so we are setting this to an empty address
      price,
      false
    );

    // We are transfering the ownership of the NFT to the marketplace contract
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price,
      false
    );
  }

  // Creates the sale of a marketplace item 
  // Transfers ownership of the item, as well as funds between parties 
  function createMarketSale(
    address nftContract,
    uint256 itemId
    ) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value); // Transfering the value to the seller 
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); // Transfering the ownership digital good from the contract address to the buyer
    idToMarketItem[itemId].owner = payable(msg.sender); 
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice); // Paying the owner of the contract
  }


    // In the below functions, we need to rebuild the arrays in memory everytime the function is called. This seems like like poor programing logic, but
    // we do this to avoid saving this to storage and spending a lot of money in gas fees

  // Returns all unsold market items 
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Returns only the items that a user has purchased 
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Returns only items a user has created 
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}