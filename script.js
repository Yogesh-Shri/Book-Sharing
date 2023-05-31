const contractAddress = '0xfeE4aa7aC594c2cAFb2491494b99E7A5BE8dB296';
let contract;
let accounts;
let currentuser;
let initialuser;

const connectWallet = async() => {
  try {
	const web3 = new Web3(window.ethereum);
	await window.ethereum.request({method: 'eth_requestAccounts'}).then((accounts) => {
		handleWalletConnected(accounts);
	}).catch((err) => {
		// displayAlert('danger', 'Error connecting wallet');
	});
	
	accounts = await web3.eth.getAccounts();
    contract = new web3.eth.Contract(contractABI, contractAddress);
	currentuser = accounts[0];
	initialuser = currentuser;
   
		// localStorage.setItem('isWalletConnected', 'true');
	getAllBookIds();
	checkBookFormVisibility();
		
	

	// currentuser = accounts[0];
	// getAllBookIds();
	// checkBookFormVisibility();
  } 
  catch (err) {
    console.log(err);
  } 

//   document.getElementById('myButton').classList.remove("hidden");
//   document.getElementById('myButton2').classList.remove("hidden");
}

document.getElementById('connectWalletBtn').addEventListener('click', ()=> {
	connectWallet();
});
  
const handleWalletConnected = async(accounts) => {
	try {
		const walletAddress = accounts[0];
		console.log("Wallet connected, address:", walletAddress);
		updateUI(walletAddress)
	}
	catch (err) {
		console.log(err);
	}
}

const updateUI = (walletAddress) => {
	try {
		const walletBtn = document.getElementById('connectWalletBtn');
		walletBtn.textContent = walletAddress;
		// walletBtn.getElementById('my_description4').style
		walletBtn.disabled = true; 
		walletBtn.classList.add('connected');

		if(walletAddress == initialuser){
			document.getElementById('myButton2').classList.remove('hidden');
		}
		else{
			document.getElementById('myButton2').classList.add('hidden');
		}
	}
	catch (err) {
		console.log(err);
	}

	
}
document.getElementById("userButton").addEventListener('click', ()=>{
	console.log('buttonvlick');
});


const getAllBookIds = async() => {
	// await 
	contract.methods.getBookIds().call().then((bookIds) =>{
		getDetails(bookIds);
	}).catch((error)=>{
		console.log(error);
	});
}

const getDetails = async(bookIds) =>{
	try{
		bookIds.forEach(bookId =>{
			contract.methods.getBookDetails(bookId).call((error,result)=>{
				if(error){
					console.error(error);
				}else{
					displayBookDetails(result);
				}
			});
		});
	}catch(err){
		console.log(err);
	}
}

const displayBookDetails = async(result) =>{
	try{
		const tableBody = document.getElementById('book_details');
		const newRow = tableBody.insertRow();

		// Insert cells in new row;
		const bookIdCell = newRow.insertCell();
		const bookTitleCell  = newRow.insertCell();
		const bookAuthorCell = newRow.insertCell();
		const bookPublisherCell = newRow.insertCell();
		const bookIsbnCell = newRow.insertCell();
		const bookBorrowerAddressCell = newRow.insertCell();
		const bookIssuerAddressCell = newRow.insertCell();
		const bookIsAvailableCell = newRow.insertCell();

		bookIdCell.textContent = result[0];
		bookTitleCell.textContent = result[1];
		bookAuthorCell.textContent = result[2];
		bookPublisherCell.textContent = result[3];
		bookIsbnCell.textContent = result[4];
		bookBorrowerAddressCell.textContent = result[5];

		const ul = document.getElementById('ul');
		result[6].forEach(address => {
			const li = document.getElementById('li');
			li.textContent = address;
			ul.appendChild(li);
		});
		bookBorrowerAddressCell.appendChild(ul);

		if(result[7] === false){
			if(currentuser === result[5]){
					const returnButton = document.createElement('button');
					returnButton.textContent = "Return";
					returnButton.style.borderRadius = "5px";
					returnButton.style.backgroundColor = "red";
					returnButton.addEventListener('click',() =>{
						returnBook(result[0]);
					});
					bookIsAvailableCell.appendChild(returnButton);
			}else{
				bookIsAvailableCell.textContent='N/A';
			}
		} else{
			const rentButton = document.createElement('button');
			rentButton.textContent = "Borrow";
			rentButton.style.borderRadius ="5px";
			rentButton.addEventListener('click', ()=>{
				issueBook(result[0]);
			});
			bookIsAvailableCell.appendChild(rentButton);
		}
	} catch(err){
		console.log(err);
	}
}
const borrowBook = async(bookId) => {
	try{
		const book = await contract.methods.borrowBook(bookId).send({from: currentuser});
		console.log(book);
	} catch(err){
		console.log(err);
	}
}
const returnBook = async(bookId) => {
	try{
		const book = await contract.methods.returnBook(bookId).send({from: currentuser});
		console.log(book);
	} catch(err){
		console.log(err);
	}
}


const checkBookFormVisibility = async() =>{
	try{
		const librarian = await contract.methods.librarian().call();
		if(librarian == currentuser){
			const addBook = document.getElementById("myButton2");
			addBook.classList.remove("hidden");

			// const form = document.getElementById("vehicleForm");
			// addvehicle.addEventListener('click',function() {
			// 	formContainer.classList.toggle('active');
			// });

			const form = document.getElementById("container2");
			form.classList.remove('hidden');
			form.addEventListener("submit", (event) =>{
				event.preventDefault();  // prevent form submission

				const title = document.getElementById("title").value;
				const author = document.getElementById("author").value;
				const publisher = document.getElementById("publisher").value;
				const isbn = document.getElementById("isbn").value;

				createBook(title, author, publisher, isbn);
				
			});

		}

	}catch(err){
		console.log(err);
	}
}

const createBook = async(title, author, publisher, isbn) =>{
	const book = await contract.methods.addBook(title, author, publisher, isbn).send({from: accounts[0]})
	console.log(book)
}




// const displayBookDetails = async() => {
// 	try{
// 		const tableBody = document.getElementById('book_details');
// 		const newRow = tableBody.insertRow();

// 		// Insert cells in New Row

// 	}
// }

// function displayAlert(type, message) {
//     const alertContainer = $('#alertContainer');
//     const alert = $('<div class="alert alert-dismissible">').addClass(`alert-${type}`).html(message).append('<button type="button" class="close" data-dismiss="alert">&times;</button>');
	

//     alertContainer.empty().append(alert);
// }
