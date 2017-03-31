var StructureInterface = artifacts.require("./structures/interfaces/StructureInterface.sol");

module.exports = function(deployer) {
  deployer.deploy(StructureInterface);
};
