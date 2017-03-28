pragma solidity ^0.4.6;

import './VegaToken.sol';

contract Project {

  struct Campaign {
    address creator;
    address beneficiary;
    uint fundingGoal;
    uint amount;
    uint duration;
    mapping (address => uint) funders;
  }

  uint numCampaigns;
  mapping (uint => Campaign) campaigns;

  function newCampaign(address beneficiary, uint goal, uint duration, address tokenAddress) external returns (uint campaignID) {
    VegaToken v = VegaToken(tokenAddress);
    if(v.getBalance(msg.sender <= 0)) throw;          // add logic here to check if when called the caller has enough Vega Tokens to create a new proposal.
    uint cost = 1;
    if(v.getBalance(msg.sender < cost)) throw;
    c.funders[msg.sender] += cost;
    v.transferFrom(msg.sender, c.beneficiary, cost);        // subtract a small amount of tokens if they have enough Tokens, put those tokens toward the amount of the proposal, they go to the project.
    campaignID = numCampaigns++;
    campaigns[campaignID] = Campaign(msg.sender, beneficiary, goal, 0, duration);
  }

  function participate(uint campaignID, uint value, address tokenAddress) external {
      VegaToken v = VegaToken(tokenAddress);
      Campaign c = campaigns[campaignID];
      if(now >= c.duration) throw;
      if(v.getBalance(msg.sender) < value) throw;
      c.funders[msg.sender] += value;
      v.transferFrom(msg.sender, c.beneficiary, value); // must first give this contract address allowence to participate
      c.amount += value;
  }

  // check goal if tokens are the amount
  function checkGoalReached(uint campaignID, uint tokenAddress) external returns (bool reached) {
    VegaToken v = VegaToken(tokenAddress);
    Campaign c = campaigns[campaignID];
    if(c.amount < c.fundingGoal) return false;
    uint amount = c.amount;
    c.amount = 0;
    v.mintTokens(10, c.creator);               // New feature, reward those who create proposals that reach their goal.
    if(!c.beneficiary.send(amount)) throw;
      return true;
  }

  function checkEthGoal(uint campaignID, address tokenAddress) external returns (bool reached) {
      VegaToken v = VegaToken(tokenAddress);
      Campaign c = campaigns[campaignID];
      uint tokenPrice = 25000000000000000000;                 // hard price as of now, until better solution for division
      uint weiSupply = tokenAddress.balance;
      uint weiAmount = c.amount * tokenPrice;
      if(weiAmount > weiSupply) throw;
      uint amount = weiAmount;
      c.amount = 0;
      weiAmount = 0;
      if(!c.beneficiary.send(amount)) throw;
      return true;
  }

  function getContribution(uint campaignID, address _address) constant returns (uint) {
      Campaign c = campaigns[campaignID];
      uint amount = c.funders[_address];
      return amount;
  }


}
