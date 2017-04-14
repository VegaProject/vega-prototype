var VegaToken = artifacts.require("./VegaToken.sol");
var Club = artifacts.require("./Club.sol");
//var EtherDeltaRef = artifacts.require("./EtherDeltaRef.sol");
var IncomingMigrationTokenInterface = artifacts.require("./IncomingMigrationTokenInterface.sol");
var OutgoingMigrationTokenInterface = artifacts.require("./OutgoingMigrationTokenInterface.sol");

module.exports = function(deployer) {
  deployer.deploy(VegaToken);
  deployer.deploy(Club);
  //deployer.deploy(EtherDeltaRef);
  deployer.deploy(IncomingMigrationTokenInterface);
  deployer.deploy(OutgoingMigrationTokenInterface);
};
