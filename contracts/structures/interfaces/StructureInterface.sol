pragma solidity ^0.4.8;

import '../../../installed_contracts/zeppelin/contracts/token/StandardToken.sol';
/*
 * Interfaces for when Project contract calls functions on invested token contracts
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */

contract EquityTokenInterface is StandardToken {
  function () payable {}
  function createToken(address recipient) payable {}
  function getPrice() constant returns (uint result) {}
}


contract CrowdsaleTokenInterface is StandardToken {
  function() payable {}
  function createToken(address recipient) payable {}
  function getPrice() {}
}
