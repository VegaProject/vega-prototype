pragma solidity ^0.4.8;

/*
 * EquityTokenInterface
 * An interface that will talk to the EquityToken contract found in structures
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */
contract EquityTokenInterface {
  function EquityToken(string _name, string _symbol, uint _decimals, uint _price, uint _maxIssue) {}
  function () payable {}
  function createToken(address recipient) payable {}
  function getPrice() constant returns (uint result) {}
}
