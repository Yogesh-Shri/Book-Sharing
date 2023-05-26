const contractAddress = '0xA7A0261F6a25D073f02CA7D177Bc6BBdae0D61f9';
let contract;
let accounts;
let currentuser;

const connectWallet = async() => {
  try {
	const web3 = new Web3(window.ethereum);
	
	accounts = await web3.eth.getAccounts();
    contract = new web3.eth.Contract(contractABI, contractAddress);

    await window.ethereum.request({method: 'eth_requestAccounts'}).then((accounts) => {
		handleWalletConnected(accounts);
		localStorage.setItem('isWalletConnected', 'true');
	}).catch((err) => {
		// displayAlert('danger', 'Error connecting wallet');
	});

	currentuser = accounts[0];
  } 
  catch (err) {
    console.log(err);
  } 
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
		walletBtn.disabled = true; 
		walletBtn.classList.add('connected');
	}
	catch (err) {
		console.log(err);
	}
}

// function displayAlert(type, message) {
//     const alertContainer = $('#alertContainer');
//     const alert = $('<div class="alert alert-dismissible">').addClass(`alert-${type}`).html(message).append('<button type="button" class="close" data-dismiss="alert">&times;</button>');
	

//     alertContainer.empty().append(alert);
// }
