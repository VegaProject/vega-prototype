var CrowdsaleToken = artifacts.require("./structures/CrowdsaleToken.sol");
var Debt = artifacts.require("./structures/Debt.sol");
var EquityToken = artifacts.require("./structures/EquityToken.sol");
var Safe = artifacts.require("./structures/Safe.sol");

module.exports = function(deployer) {
  deployer.deploy(CrowdsaleToken);
  deployer.deploy(Debt);
  deployer.deploy(EquityToken);
  deployer.deploy(Safe);.
};
