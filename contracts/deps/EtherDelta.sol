pragma solidity ^0.4.8;

/*
 * EtherDelta interface
 */

contract EtherDelta {

  function deposit() payable {}

  function withdraw(uint amount) {}

  function depositToken(address token, uint amount) {}

  function withdrawToken(address token, uint amount) {}

  function balanceOf(address token, address user) constant returns (uint) {}

  function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) {}

  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) {}

  function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) {}
}
