pragma solidity ^0.4.8;
import './deps/StandardToken.sol';

contract VegaTokenTest is StandardToken {
  function creatorsDeposit(_requestedAmount) constant returns (uint) {
    return 5;
  }

  uint public finders = 15;
}
