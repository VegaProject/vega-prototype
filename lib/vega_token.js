const Web3 = require('web3')

export default class {

  constructor (VegaToken, vegaAddress, provider, fromAddress) {
    this.web3 = new Web3(provider)

    VegaToken.setProvider(provider)
    VegaToken.defaults({
      from: fromAddress,
      gas: 400000
    })
    this.vega = VegaToken.at(vegaAddress)
  }
  // What an entry contains --
  /* enum Mode { Open, Auction, Owned, Forbidden }
  struct entry {
      Mode status;
      Deed deed;
      uint registrationDate;
      uint value;
      uint highestBid;
  } */
  transfer(amount, receiver) {
    console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.vega.transfer(receiver, this.web3.toWei(amount, 'ether')).then(function() {      
      console.log("Transfer complete!");
    }).catch(function(e) {
      console.log(e);
      console.log("Error sending tokens; see log.");
    });
  }
  transferFrom(account, receiver, amount) {
    console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.vega.transferFrom(account, receiver, this.web3.toWei(amount, 'ether')).then(function() {      
      console.log("Transfer complete!");
    }).catch(function(e) {
      console.log(e);
      console.log("Error sending tokens; see log.");
    });
  }  
  approve(amount, spender) {
    console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.vega.approve(spender, this.web3.toWei(amount, 'ether')).then(function() {      
      console.log("Transfer approved!");
    }).catch(function(e) {
      console.log(e);
      console.log("Error sending tokens; see log.");
    });
  }
  balanceOf(account) {
    console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.vega.balanceOf(account).then(function(result) {      
      console.log('Account ' + account + " has " + result.c );
    }).catch(function(e) {
      console.log(e);
      console.log("Error getting balance; see log.");
    });
  }
}