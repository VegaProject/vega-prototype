pragma solidity ^0.4.6;
/*
import "../../StandardToken.sol";
/*
 * CrowdsaleToken
 *
 * Simple ERC20 Token example, with crowdsale token creation

contract CrowdsaleToken is StandardToken {

  string public name;
  string public symbol;
  uint public decimals;
  uint public price;

  function CrowdsaleToken(string _name, string _symbol, uint _decimals, uint _price) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    price = _price;
  }

  function () payable {
    createTokens(msg.sender);
  }

  function createTokens(address recipient) payable {
    if (msg.value == 0) {
      throw;
    }

    uint tokens = safeMul(msg.value, getPrice());

    totalSupply = safeAdd(totalSupply, tokens);
    balances[recipient] = safeAdd(balances[recipient], tokens);
  }

  // replace this with any other price function
  function getPrice() constant returns (uint result) {
    return price;
  }
}
 */