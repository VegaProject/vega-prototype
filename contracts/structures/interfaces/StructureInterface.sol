pragma solidity ^0.4.8;

/*
 * Interfaces to deal structures
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */
contract EquityTokenInterface {
  function () payable {}
  function createToken(address recipient) payable {}
  function getPrice() constant returns (uint result) {}
}

contract CrowdsaleTokenInterface {
  function() payable {}
  function createToken(address recipient) payable {}
  function getPrice() {}
}
