pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Project.sol';

contract Liquidate is Project {
  enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

  enum Exchange { EtherDelta, MakerMarket }
  Exchange choice;
  Exchange constant defaultChoice = Exchange.EtherDelta;


  function sell(uint campaignID, uint price, uint amount) external returns (bool success){
    // instance of EtherDelta as e
    uint stake = getContribution(campaignID, msg.sender);
    // place order using functions of e

  }
}
