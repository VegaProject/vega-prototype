pragma solidity ^0.4.8;
import './deps/StandardToken.sol';

contract VegaTokenTest is StandardToken {
  
    uint public finders = 15;
    uint public quorum = 300;
    
  function creatorsDeposit(uint _requestedAmount) constant returns (uint) {
    return _requestedAmount * 5;
  }
  

}
