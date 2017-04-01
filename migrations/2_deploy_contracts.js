var VegaToken = artifacts.require("./VegaToken.sol");
var Project = artifacts.require("./Project.sol");
var Liquidate = artifacts.require("./Liquidate.sol");
var ProxyContract = artifacts.require("./Proxy.sol");
var FundOffering = artifacts.require("./FundOffering.sol");
var IncomingMigrationTokenInterface = artifacts.require("./IncomingMigrationTokenInterface.sol");
var OutgoingMigrationTokenInterface = artifacts.require("./OutgoingMigrationTokenInterface.sol");

module.exports = function(deployer) {
  deployer.deploy(VegaToken);
  deployer.deploy(Project);
  deployer.deploy(Liquidate);
  deployer.deploy(ProxyContract);
  deployer.deploy(FundOffering);
  deployer.deploy(IncomingMigrationTokenInterface);
  deployer.deploy(OutgoingMigrationTokenInterface);
};
