pragma solidity ^0.4.8;

/*
 * EquityTokenInterface
 * An interface that will talk to the EquityToken contract found in structures
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */
contract EquityTokenInterface {
  function () payable {}
  function createToken(address recipient) payable {}
  function getPrice() constant returns (uint result) {}
}
