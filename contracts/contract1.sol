// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LibraryBooks is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Book {
        string title;
        string author;
        string publisher;
        string isbn;
        bool isAvailable;
        string borrowerRollNo; // Added field to track borrower roll number
    }

    mapping(uint256 => Book) public books;

    constructor() ERC721("Library Books", "LBK") {}

    function mintBook(address recipient, string memory title, string memory author, string memory publisher, string memory isbn) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        books[newTokenId] = Book(title, author, publisher, isbn, true, ""); // Initialize borrower roll number to empty string
        _mint(recipient, newTokenId);

        return newTokenId;
    }

    function borrowBook(uint256 tokenId, string memory borrowerRollNo) public {
        require(_exists(tokenId), "Book does not exist");
        require(books[tokenId].isAvailable == true, "Book is not available");

        books[tokenId].isAvailable = false;
        books[tokenId].borrowerRollNo = borrowerRollNo; // Set borrower roll number
    }

    function returnBook(uint256 tokenId) public {
        require(_exists(tokenId), "Book does not exist");
        require(books[tokenId].isAvailable == false, "Book is already available");

        books[tokenId].isAvailable = true;
        books[tokenId].borrowerRollNo = ""; // Reset borrower roll number
    }
}
