pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Project.sol';
import 'etherdelta.github.io/smart_contract/etherdelta.sol';

contract Liquidate is Project {
  enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

  enum Exchange { EtherDelta, MakerMarket }
  Exchange choice;
  Exchange constant defaultChoice = Exchange.EtherDelta;

  function deposit(uint campaignID, uint amount, address _exchangeAddr) {
    // instance of EtherDelta as e
    uint stake = getContribution(campaignID, msg.sender);
    if(stake < amount) throw;                 // check if amount to sell is less than or equal to what the seller has
    EtherDelta e = EtherDelta(_exchangeAddr);
    address tokenAddr = getTokenAddress(campaignID); // getting address of benificary
    e.depositToken(tokenAddr, amount); // deposit tokens into etheredelta
    // call deposit function, will record the tokens to the msg.sender account, which in this
    // case is the address of "this" liquidation contract
  }

  function sell(uint campaignID, uint price, uint amount) external returns (bool success){
    // instance of EtherDelta as e
    uint stake = getContribution(campaignID, msg.sender);
    // place order using functions of e

  }
}
