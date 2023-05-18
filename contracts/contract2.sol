// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LibraryBooks is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    struct Book {
        string title;
        string author;
        string publisher;
        string isbn;
        bool isAvailable;
        string borrowerRollNo;
        uint256 borrowTimestamp;
    }

    struct User {
        bool isRegistered;
        uint256 securityDeposit;
        uint256 fineAmount;
    }

    mapping(uint256 => Book) public books;
    mapping(address => User) public users;

    uint256 public maxBorrowDuration;
    uint256 public securityDepositAmount;
    uint256 public fineRate;

    event BookBorrowed(uint256 indexed tokenId, string borrowerRollNo, uint256 borrowTimestamp);
    event BookReturned(uint256 indexed tokenId);
    event UserRegistered(address indexed user, uint256 securityDeposit);
    event FinePaid(address indexed user, uint256 amount);

    constructor() ERC721("Library Books", "LBK") {
        maxBorrowDuration = 14 days;
        securityDepositAmount = 0.1 ether;
        fineRate = 0.00001 ether;
    }

    function mintBook(
        address recipient,
        string memory title,
        string memory author,
        string memory publisher,
        string memory isbn
    ) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        books[newTokenId] = Book(title, author, publisher, isbn, true, "", 0);
        _mint(recipient, newTokenId);

        return newTokenId;
    }


    function registerUser() public payable {
        require(!users[msg.sender].isRegistered, "User is already registered");
        require(msg.value >= securityDepositAmount, "Insufficient security deposit amount");

        users[msg.sender] = User(true, msg.value, 0);

        emit UserRegistered(msg.sender, msg.value);
    }

    function borrowBook(uint256 tokenId, string memory borrowerRollNo) public {
        require(_exists(tokenId), "Book does not exist");
        require(books[tokenId].isAvailable, "Book is not available");
        require(users[msg.sender].isRegistered, "User is not registered");

        books[tokenId].isAvailable = false;
        books[tokenId].borrowerRollNo = borrowerRollNo;
        books[tokenId].borrowTimestamp = block.timestamp;

        emit BookBorrowed(tokenId, borrowerRollNo, block.timestamp);
    }


    function calculateFine(uint256 returnTimestamp, uint256 borrowTimestamp) internal view returns (uint256) {
    uint256 borrowDuration = returnTimestamp.sub(borrowTimestamp);
    uint256 overdueDays = borrowDuration.div(1 days); // Assuming 1 day is the unit for calculating fines
    uint256 fineAmount = 0;

    if (overdueDays > 14) {
        uint256 extraDays = overdueDays.sub(14);
        fineAmount = extraDays.mul(fineRate);
    }

    return fineAmount;
}
function returnBook(uint256 tokenId) public {
    require(_exists(tokenId), "Book does not exist");
    require(!books[tokenId].isAvailable, "Book is already available");
    require(users[msg.sender].isRegistered, "User is not registered");

    uint256 borrowTime = books[tokenId].borrowTimestamp;
    require(block.timestamp >= borrowTime.add(maxBorrowDuration), "Book cannot be returned before the borrow duration");

    uint256 fineAmount = calculateFine(block.timestamp, borrowTime);

    // Charge fine if applicable
    if (fineAmount > 0) {
        require(users[msg.sender].securityDeposit >= fineAmount, "Insufficient security deposit for the fine");
        users[msg.sender].fineAmount = users[msg.sender].fineAmount.add(fineAmount);
        users[msg.sender].securityDeposit = users[msg.sender].securityDeposit.sub(fineAmount);
        emit FinePaid(msg.sender, fineAmount);

        // Transfer fine to contract owner
        payable(owner()).transfer(fineAmount);
    }

    books[tokenId].isAvailable = true;
    books[tokenId].borrowerRollNo = "";
    books[tokenId].borrowTimestamp = 0;

    emit BookReturned(tokenId);
}



}
