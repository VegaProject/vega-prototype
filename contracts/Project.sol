pragma solidity ^0.4.6;

import './VegaToken.sol';
//import './Liquidate.sol';
//import './StructureInterfaces.sol';
import './deps/SafeMath.sol';

/*
 * Project Campaigns
 * Description: TODO
 */


contract Project is SafeMath {

  struct Campaign {
    address creator;
    address beneficiary;
    uint fundingGoal;
    uint amount;
    uint duration;
    bool action;
    mapping (address => uint) funders;
  }

  uint numCampaigns;
  mapping (uint => Campaign) campaigns;

  function newCampaign(address beneficiary, uint goal, uint duration, address tokenAddress) external returns (uint campaignID) {
    VegaToken v = VegaToken(tokenAddress);
    uint cost = 1;                                  // hard cost as of now
    campaignID = numCampaigns++;
    campaigns[campaignID] = Campaign(msg.sender, beneficiary, goal, 0, duration, false);
    Campaign c = campaigns[campaignID];
    v.investTokens(c.creator, cost);                  // removes tokens from users balance and total supply (out of curculation)
  }

  function participate(uint campaignID, uint value, address tokenAddr) external {
    VegaToken v = VegaToken(tokenAddr);
    Campaign c = campaigns[campaignID];
    //if(now >= c.duration) throw;                    // will deal with later, for testing just commented out
    if(v.balanceOf(msg.sender) < value) throw;
    c.funders[msg.sender] += value;
    c.amount += value;
    v.investTokens(msg.sender, value);                // removes tokens from users balance and total supply (out of curculation)
  }

  function getContribution(uint campaignID, address _address) constant returns (uint) {
    Campaign c = campaigns[campaignID];
    uint amount = c.funders[_address];
    return amount;
  }

  function getBenificiary(uint campaignID) constant returns (address) {
      Campaign c = campaigns[campaignID];
      address who = c.beneficiary;
      return who;
  }

  function getFundBalance(address tokenAddr) constant returns (uint) {
    VegaToken v = VegaToken(tokenAddr);
    return v.balance;
  }

  function getTokenBalance(uint campaignID, address tokenAddr) constant returns (uint) {
    VegaToken v = VegaToken(tokenAddr);
    Campaign c = campaigns[campaignID];
    //EquityTokenInterface Eti = EquityTokenInterface(c.beneficiary);
    //return Eti.balanceOf(v);
  }

}
