const Web3 = require('web3')

export default class {

  constructor (VegaToken, vegaAddress, Project, projectAddress, provider, fromAddress) {
    this.web3 = new Web3(provider)

    VegaToken.setProvider(provider)
    VegaToken.defaults({
      from: fromAddress,
      gas: 400000
    })

    Project.setProvider(provider)
    Project.defaults({
      from: fromAddress,
      gas: 400000
    })
    this.vega = VegaToken.at(vegaAddress)
    this.project = Project.at(projectAddress)
    this.project.newVegaToken(vegaAddress)
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
  newOffer(num, den, amount, openFor, recipient, token, description, salt) {
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.newOffer(num, den, amount, openFor, recipient, token, description, salt).then(function(result) {      
      console.log('Offer ' + salt + " has id " + JSON.stringify(result) + result );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });
  }
  vote(offerId, salt) {
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.offerVote(offerId, salt).then(function(result) {      
      console.log('Vote for ' + offerId + " was succesful " );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });
  }
  countVotes(offerId) {
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.countVotes(offerId).then(function(result) {      
      console.log('Vote status ' + result );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });
  }  
  execute(offerId, salt){
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.executeOffer(offerId, salt).then(function(result) {      
      console.log('Executing offer ' + offerId + " was succesful " );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });    
  }
  getOfferStatus(offerId){
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.getOfferStatus(offerId).then(function(result) {      
      console.log('Offer status ' + result  );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });     
  }
}