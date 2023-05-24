const BookSharingPlatform = artifacts.require("LibraryBooks");

module.exports = (deployer, network, accounts) => {
  const verifierAdd = accounts[0];
  deployer.deploy(BookSharingPlatform);
};