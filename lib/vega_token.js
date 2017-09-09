const Web3 = require('web3')

export default class {

  constructor (VegaToken, vegaAddress, Project, projectAddress, provider, fromAddress, CDR, cdrAddress) {
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
    this.cdr = CDR.at(cdrAddress)
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
      console.log('Offer ' + description + " has id "  + result.logs[0].args._offerId );
    }).catch(function(e) {
      console.log(e);
      console.log("Error establishing Offer; see log.");
    });
  }
  vote(offerId, support) {
        console.log("Initiating transaction... (moving tokenes through the net..)");
    return this.project.offerVote(offerId, support).then(function(result) {      
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
  calcCDR(_currentValue, _startingValue, _vegaPeriods, _stake, _absTotalRewards, _tokenConverison, _currentBalance){
        console.log("Initiating CDR calculations... (All Number crunching powered by witchcraft...)");
    return this.cdr.calculateCDRForPositiveOutcome(_currentValue, _startingValue, _vegaPeriods, _stake, _absTotalRewards, _tokenConverison, _currentBalance).then(function(result) {      
      console.log('CDR result ' + result  );
    }).catch(function(e) {
      console.log(e);
      console.log("Error getting CDR; see log.");
    });     
  }
}