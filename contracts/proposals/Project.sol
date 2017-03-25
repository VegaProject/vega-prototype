pragma solidity ^0.4.6;

import '../VegaToken.sol';

contract Project is VegaToken{

  struct Campaign {
    address beneficiary;
    uint fundingGoal;
    uint amount;
    mapping (address => uint) funders;
  }

  uint numCampaigns;
  mapping (uint => Campaign) campaigns;

  function newCampaign(address beneficiary, uint goal) returns (uint campaignID) {
    campaignID = numCampaigns++;
    campaigns[campaignID] = Campaign(beneficiary, goal, 0);
  }

  function participate(uint campaignID, uint value) {
    if(balances[msg.sender] < value) throw;
    Campaign c = campaigns[campaignID];
    c.funders[msg.sender] += value;
    c.amount += value;
  }

  function checkGoalReached(uint campaignID) returns (bool reached) {
    Campaign c = campaigns[campaignID];
    if(c.amount < c.fundingGoal) return false;
    uint amount = c.amount;
    c.amount = 0;
    if(!c.beneficiary.send(amount)) throw;
      return true;
  }
}
