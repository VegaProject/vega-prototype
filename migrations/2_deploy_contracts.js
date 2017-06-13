var VegaTokenTest = artifacts.require("./VegaTokenTest.sol");
var Project = artifacts.require("./offers/Project.sol");

module.exports = function(deployer) {
  deployer.deploy(
    VegaTokenTest,
    web3.eth.accounts[0],
    web3.eth.accounts[0],
    web3.eth.accounts[0]
  );
  deployer.deploy(
    Project
  );
};
