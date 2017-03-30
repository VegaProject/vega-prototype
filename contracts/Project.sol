pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Liquidate.sol';
import './EquityTokenInterface.sol'

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
  }

  function participate(uint campaignID, uint value, address tokenAddress) external {
    VegaToken v = VegaToken(tokenAddress);
    Campaign c = campaigns[campaignID];
    //if(now >= c.duration) throw;                    // will deal with later, for testing just commented out
    if(v.balanceOf(msg.sender) < value) throw;
    c.funders[msg.sender] += value;
    v.transferFrom(msg.sender, c.beneficiary, value); // must first give this contract address allowence to participate
    c.amount += value;
  }

  /* check goal in terms of tokens not fund balance
   * working, just commented for reference:
  function checkGoalReached(uint campaignID) returns (bool reached) {
    Campaign c = campaigns[campaignID];
    if(c.amount < c.fundingGoal) return false;
    uint amount = c.amount;
    c.amount = 0;
    if(!c.beneficiary.send(amount)) throw;
      return true;
  }
  */

  function checkEthGoal(uint campaignID, address tokenAddr) external returns (bool reached) {
    Campaign c = campaigns[campaignID];
    uint fundBalance = getFundBalance(tokenAddr);
    if(c.amount < c.fundingGoal) return false;
    uint ethTokenPrice = 1;                                 // hard price, once ready change to lowest bid price
    uint value = c.amount * ethTokenPrice;
    c.amount = 0;
    if(value < fundBalance) throw;
    c.funders[c.creator] += 2;                          // reward for successful campaign, get the cost back plus 1 token, hard price as of now, could change later
    if(!c.beneficiary.send(value)) throw;
    return true;
  }

  function getContribution(uint campaignID, address _address) constant returns (uint) {
    Campaign c = campaigns[campaignID];
    uint amount = c.funders[_address];
    return amount;
  }

  function getFundBalance(address tokenAddr) constant returns (uint) {
    VegaToken v = VegaToken(tokenAddr);
    return v.balance;
  }

  function getTokenBalance(uint campaignID) constant returns (uint) {
    Campaign c = campaigns[campaignID];
    EquityTokenInterface Eti = EquityTokenInterface(c.beneficiary);
  }

}
