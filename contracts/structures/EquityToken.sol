pragma solidity ^0.4.8;

import "./VestedToken.sol";
/*
 * CrowdsaleToken
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */
contract EquityToken is VestedToken {

  string public name;
  string public symbol;
  uint public decimals;
  uint public price;
  uint public totalSupply;
  uint public max_supply;


  function EquityToken(string _name, string _symbol, uint _decimals, uint _price, uint _max_issue) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    price = _price;
    max_supply = _max_issue;
  }

  function () payable {
    createTokens(msg.sender);
  }

  function createTokens(address recipient) payable {
    if (msg.value == 0) {
      throw;
    }
    if(totalSupply >= max_supply) throw;
    uint tokens = safeMul(msg.value, getPrice());
    totalSupply = safeAdd(totalSupply, tokens);
    balances[recipient] = safeAdd(balances[recipient], tokens);
  }

  // replace this with any other price function
  function getPrice() constant returns (uint result) {
    return price;
  }
}