pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Liquidate.sol';

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
    uint cost = 1;                                  // hard cost as of now
    campaignID = numCampaigns++;
    campaigns[campaignID] = Campaign(msg.sender, beneficiary, goal, 0, duration);
    Campaign c = campaigns[campaignID];
    // no need to do a balances check, because the user will have to approve before, and that takes care of balance checks.
    v.transferFrom(msg.sender, c.beneficiary, cost);
    c.funders[msg.sender] += cost;
  }

  function participate(uint campaignID, uint value, address tokenAddress) external {
      VegaToken v = VegaToken(tokenAddress);
      Campaign c = campaigns[campaignID];
      //if(now >= c.duration) throw;                    // will deal with later, for testing just commented out
      if(v.getBalance(msg.sender) < value) throw;
      c.funders[msg.sender] += value;
      v.transferFrom(msg.sender, c.beneficiary, value); // must first give this contract address allowence to participate
      c.amount += value;
  }

  // check goal if tokens are the amount
  function checkGoalReached(uint campaignID, uint liquidateAddr) external returns (bool reached) {
    //VegaToken v = Liquidate(liquidateAddr);
    Campaign c = campaigns[campaignID];
    if(c.amount < c.fundingGoal) return false;
    uint amount = c.amount;
    c.amount = 0;
    //v.mint(c.creator, 10);               // New feature, reward those who create proposals that reach their goal.
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
