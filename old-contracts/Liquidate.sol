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
//import './EtherDelta.sol';

contract Liquidate is Project {

  struct Rewards {                                            // use struct for paying back returns just like paying campaigns in proposal creation. Keeps track of stuff
    uint amount;
    mapping (address => uint) funders;
  }

  /// STEPS
  /// 1. Deposit the users tokens of c.beneficiary in etherdelta
  /// 2. Allow the users to make orders and trade in etherdelta
  /// 3. Withdrawl from etherdelta
  /// 4. Check how much loss or return the user made on the investment
  /// 5. Set the payout value (Vega Tokens) relitive to what they made or lost
  /// 6. The Vega Token contract mint function will look at what the payout value is.

  /// just for testing
  function getPayout(uint _campaignID) returns (uint) {
      uint stake = getContribution(_campaignID, msg.sender);
      if(stake < 0) throw;
      return stake;
  }

  function getPayoutFromManager(uint campaignID) returns (uint) {
      uint amount = 5;
      return amount;
  }

}
