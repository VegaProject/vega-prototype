pragma solidity ^0.4.6;

import './VegaToken.sol';

contract Project {

  struct Campaign {
    address beneficiary;
    uint fundingGoal;
    uint amount;
    uint duration;
    mapping (address => uint) funders;
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
      //if(now >= c.duration) throw;
      if(v.getBalance(msg.sender) < value) throw;
      c.funders[msg.sender] += value;
      v.transferFrom(msg.sender, c.beneficiary, value); // must first give this contract address allowence to participate
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

  function getContribution(uint campaignID, address _address) constant returns (uint) {
      Campaign c = campaigns[campaignID];
      uint amount = c.funders[_address];
      return amount;
  }

}
