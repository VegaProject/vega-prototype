pragma solidity ^0.4.6;

import './VegaToken.sol';

contract Project {

  struct Campaign {
    address beneficiary;
    uint fundingGoal;
    uint amount;                      // total amount of funders balance in Vega Tokens
    uint duration;
    mapping (address => uint) funders; // when someone participates they move vega tokens to the funders balance.
  }

  uint numCampaigns;
  mapping (uint => Campaign) campaigns;

  function newCampaign(address beneficiary, uint goal, uint duration) returns (uint campaignID) {
    campaignID = numCampaigns++;
    campaigns[campaignID] = Campaign(beneficiary, goal, 0, duration);
  }

  function participate(uint campaignID, uint value, address tokenAddress) external {
      VegaToken v = VegaToken(tokenAddress);
      Campaign c = campaigns[campaignID];
      if(now >= c.duration) throw;
      if(v.getBalance(msg.sender) < value) throw;
      c.funders[msg.sender] += value;                   // keep track of who used tokens to fund the project
      v.transferFrom(msg.sender, c.beneficiary, value); // must first give this contract address allowence to participate before participating, also this transfers tokens to the project from the senders balance.
      c.amount += value;
  }

  // check goal if tokens are the amount
  function checkGoalReached(uint campaignID) returns (bool reached) {
    Campaign c = campaigns[campaignID];
    if(c.amount < c.fundingGoal) return false;
    uint amount = c.amount;
    c.amount = 0;
    if(!c.beneficiary.send(amount)) throw;
      return true;
  }

  function checkEthGoal(uint campaignID, address tokenAddress) external returns (bool reached) {
      VegaToken v = VegaToken(tokenAddress);
      Campaign c = campaigns[campaignID];
      uint tokenPrice = 25000000000000000000;                 // hard price as of now, until better solution for division
      uint weiSupply = tokenAddress.balance;                  // get balance of the token contract in wei
      uint weiAmount = c.amount * tokenPrice;               // campaign token balance x the current crowdfunding price of the token, depending on how the tokens are sold will determin the price.
      if(weiAmount > weiSupply) throw;
      if(c.amount < c.fundingGoal) return false;
      uint amount = weiAmount;
      c.amount = 0;
      weiAmount = 0;
      if(!c.beneficiary.send(amount)) throw;                // may have to fix to make sure to send ether as wei, not just uint
      return true;
  }

  function getContribution(uint campaignID, address _address) constant returns (uint) {
      Campaign c = campaigns[campaignID];
      uint amount = c.funders[_address];
      return amount;
  }

  function getTokenAddress(uint campaignID) constant returns (address) {
    Campaign c = campaigns[campaignID];
    address tokenAddr = c.beneficiary;
    return tokenAddr;
  }


}
