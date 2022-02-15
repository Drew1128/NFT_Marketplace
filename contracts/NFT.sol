// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // provides additional functionality to set the tokenURI
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFT is ERC721URIStorage { // Inheriting from ERC721URIStorage which is actually inheriting from ERC721.sol
    using Counters for Counters.Counter; // "using" keyword is available because Counters is a library
    Counters.Counter private _tokenIds; // This to assign a unique identifier for each token. The "private" keyword is a visibility modifier that is only callable from other functions from inside the contract
    address contractAddress; // This is going to be the address of the marketplace that we want to allow the NFT to interact with  

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "META") { // The constructor is only called once during deployment
        contractAddress = marketplaceAddress; // We are taking in the marketplace address when we deoply this contract. Then we are setting it to the contractAddress
    }

    function createToken(string memory tokenURI) public returns (uint) { //The "public" visibility modifier means that this contract can be called from from anywhere 
        _tokenIds.increment(); 
        uint256 newItemId = _tokenIds.current(); 

        _mint(msg.sender, newItemId); // This function is available from ERC721.sol
        _setTokenURI(newItemId, tokenURI); // The setTokenURI utility was made available from ERC721Storage.sol
        setApprovalForAll(contractAddress, true); // This function is available from ERC721.sol
        return newItemId; // This will make it available on the client
    }
}