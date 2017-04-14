// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";
// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import vega_artifacts from '../../build/contracts/VegaToken.json';

// MetaCoin is our usable abstraction, which we'll use through the code below.
var VegaToken = contract(vega_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;

window.App = {

  start: function() {
    var self = this;

    // Get VegaToken abstraction
    VegaToken.setProvider(web3.currentProvider);

    // Get initial account balance on display
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error getting your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Cannot get accounts. Make sure the Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.refreshBalance();
    });

  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  refreshBalance: function() {
    var self = this;

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.balanceOf.call(account, {from: account});
    }).then(function(value) {
      var balance_element = document.getElementById("balance");
      balance_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see log.");
    });
  },

  transfer: function() {
    var self = this;

    var amount = parseInt(document.getElementById("amount").value);
    var receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (moving tokenes through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.transfer(receiver, amount, {from: account});
    }).then(function() {
      self.setStatus("Transfer complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending tokens; see log.");
    });
  },

  transferFrom: function(from, to, value) {
    var self = this;

    this.setStatus("Initiating transaction... (moving tokenes through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.transferFrom(from, to, value, {from: account});
    }).then(function() {
      self.setStatus("transferFrom complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending tokens from; see log.");
    });

  },

  approve: function(spender, value) {
    var self = this;

    this.setStatus("Initiating transaction... (moving your request through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.approve(spender, value, {from: account});
    }).then(function() {
      self.setStatus("approved spender complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error approving spender; see log.");
    });
  },

  approveSelfSpender: function(spender, value) {
    var self = this;

    this.setStatus("Initiating transaction... (moving your request through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.approveSelfSpender(spender, value, {from: account});
    }).then(function() {
      self.setStatus("approved self spender complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error approving spender; see log.");
    });
  },

  changeMigrationMaster: function(master) {
    var self = this;

    this.setStatus("Initiating transaction... (moving your request through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.changeMigrationMaster(master, {from: account});
    }).then(function() {
      self.setStatus("Migration master change complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error changing migration master; see log.");
    });
  },

  changeClubAddr: function(addr) {
    var self = this;

    this.setStatus("Initiating transaction... (moving your request through the net..)");

    var vega;
    VegaToken.deployed().then(function(instance) {
      vega = instance;
      return vega.changeMigrationMaster(master, {from: account});
    }).then(function() {
      self.setStatus("Club address change complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error changing club address; see log.");
    })
  }
},
// functions to add:
DepositAndCreateOrderProjectTokens(uint liquidationID)
WithdrawEther(uint liquidationID)
changeEtherDeltaAddr(address _etherDeltaAddress)
finalizeOutgoingMigration()
beginMigrationPeriod(address _newTokenAddress)
migrateToNewContract(uint _value)
rewardFinder(uint proposalID)


window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
