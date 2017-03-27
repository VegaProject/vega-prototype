pragma solidity ^0.4.6;

/*
Idea:
When someone sells they first deposit their tokens from the campaign into
EtherDelta contract. Then they call a function to order or trade to
Ether. They then withdrawl from EtherDelta. The program then looks to
see how much Ether they put into the project originally and how much they
were able to withdrawl from EtherDelta. If they happen to withdrawl more
than they put in, they will receive new minted Vega tokens as a reward for
their performance. This is done through looking at the address of funders, not
the tokens.
If they withdrawl less than they put into the project, they will not receive
any new Vega Tokens, and the ether will be put back into the fund (the token address). The Idea
is to only reward people based on their performance.
*/

import './VegaToken.sol';
import './Project.sol';
import '../installed_contracts/etherdelta/EtherDelta.sol';

contract Liquidate is Project {


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
    if(stake < amount) throw;                 // check if amount to sell is less than or equal to what the seller has
    EtherDelta e = EtherDelta(_exchangeAddr);
    address tokenAddr = getTokenAddress(campaignID);
    //e.trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount);
  }


}
