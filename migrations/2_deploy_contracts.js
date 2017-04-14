var VegaToken = artifacts.require("./VegaToken.sol");
var Club = artifacts.require("./Club.sol");
var EtherDelta = artifacts.require("./EtherDelta.sol");
//var IncomingMigrationTokenInterface = artifacts.require("./IncomingMigrationTokenInterface.sol");
//var OutgoingMigrationTokenInterface = artifacts.require("./OutgoingMigrationTokenInterface.sol");

module.exports = function(deployer) {
  deployer.deploy(VegaToken, web3.eth.accounts[0], web3.eth.accounts[0], web3.eth.accounts[0]);
  deployer.deploy(Club);
  deployer.deploy(EtherDelta);
  //deployer.deploy(IncomingMigrationTokenInterface);
  //deployer.deploy(OutgoingMigrationTokenInterface);
};
