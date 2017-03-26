var VegaToken = artifacts.require("./VegaToken.sol");
var Project = artifacts.require("./Project.sol");
var IncomingMigrationTokenInterface = artifacts.require("./IncomingMigrationTokenInterface.sol");
var OutgoinMigrationTokenInterface = artifacts.require("./OutgoinMigrationTokenInterface.sol");


module.exports = function(deployer) {
  deployer.deploy(VegaToken);
  deployer.deploy(Project);
  deployer.deploy(IncomingMigrationTokenInterface);
  deployer.deploy(OutgoinMigrationTokenInterface);
};
