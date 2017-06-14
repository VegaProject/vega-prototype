var VegaToken = artifacts.require("./VegaToken.sol");
var Project = artifacts.require("./offers/Project.sol");
var Rewards = artifacts.require('./offers/Rewards.sol');
var Finders = artifacts.require('./offers/Finders.sol');
var Quorum = artifacts.require('./offers/Quorum.sol');

module.exports = function(deployer) {
  deployer.deploy(Project).then((project) => {
    deployer.deploy(Rewards).then((rewards) => {
      deployer.deploy(Finders).then((finders) => {
        deployer.deploy(Quorum).then((instance) => {
          console.log(web3.eth.accounts[0])
            deployer.deploy(
              VegaToken,
              web3.eth.accounts[0],
              Project.address,
              Rewards.address,
              Finders.address,
              Quorum.address
            ).catch(function(e){
            console.log(e)
        })
        }).catch(function(e){
            console.log(e)
        })
      }).catch(function(e){
          console.log(e)
      })
    }).catch(function(e){
        console.log(e)
    })
  }).catch(function(e){
      console.log(e)
  })  
}
