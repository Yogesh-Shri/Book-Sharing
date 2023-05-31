// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LibraryBooks is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    struct Book {
        uint256 id;
        string title;
        string author;
        string publisher;
        string isbn;
        address borrowerAddress;
        address[] issuers;
        bool isAvailable;
    }

    struct User {
        string name;
        string email;
        string contactNo;
        string gender;
        string idType;
        string idNo;
        address userAddress;
        bool isRegistered;
    }

    mapping(uint256 => Book) public _books;
    mapping(address => User) public _users;

    address public librarian;

    constructor() ERC721("Library Books", "LBK") {
        librarian = msg.sender;
    }

    modifier onlyLibrarian(){
        require(msg.sender == librarian, "Unauthorized");
        _;
    }

    function registerUser(
        string memory name,
        string memory email,
        string memory contactNo,
        string memory gender,
        string memory idType,
        string memory idNo
        // address userAddress,
        // bool isRegistered
        ) external {
            require(!_users[msg.sender].isRegistered, "User is already registered");

        User storage user = _users[msg.sender];
        user.name = name;
        user.email = email;
        user.contactNo = contactNo;
        user.gender = gender;
        user.idType = idType;
        user.idNo = idNo;
        user.userAddress = msg.sender;
        user.isRegistered = false;
        }

        function addBook(string memory title, string memory author, string memory publisher, string memory isbn) external onlyLibrarian(){
            _tokenIds.increment();
            uint256 bookId = _tokenIds.current();
            _mint(msg.sender, bookId);

            Book storage newBook = _books[bookId];
            newBook.id = bookId;
            newBook.title = title;
            newBook.author = author;
            newBook.publisher = publisher;
            newBook.isbn = isbn;
            newBook.borrowerAddress = address(0);
            newBook.isAvailable = true;
        }

        function getBookDetails(uint256 bookId) external view returns(uint256, string memory, string memory,string memory,string memory,address, address[] memory ,bool){
            Book storage book = _books[bookId];
            return(
                book.id,
                book.title,
                book.author,
                book.publisher,
                book.isbn,
                book.borrowerAddress,
                book.issuers,
                book.isAvailable
            );
        }

        function getBookIds() external view returns(uint256[] memory){
            uint256[] memory bookIds = new uint256[](_tokenIds.current());
            for(uint256 i =1 ;i<= _tokenIds.current(); i++){
                bookIds[i-1] = i;
            }
            return bookIds;
        }
        function borrowBook(uint256 bookId) external{
            Book storage book = _books[bookId];
            require(book.borrowerAddress == address(0),"Aleady Borrowed");
//
            book.borrowerAddress = msg.sender;
            book.issuers.push(msg.sender);
            book.isAvailable = false;
        }

        function returnBook(uint256 bookId) external {
            Book storage book = _books[bookId];
            require(book.borrowerAddress == msg.sender,"You didn't rent it.");

            book.borrowerAddress = address(0);
            book.isAvailable = true;
        }

}