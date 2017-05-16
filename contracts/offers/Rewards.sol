pragma solidity ^0.4.8;
import './../deps/Ownable.sol';
import './../VegaToken.sol';

/// @title Rewards contract - Rewards Offer.
/// @author George K. Van Hoomissen - <georgek@vega.fund>
contract Rewards {
    uint public numerator = 5;
    uint public denominator = 10;
      mapping (address => uint) public points;
  mapping (address => mapping(address => uint)) public extraPoints;
    function removePoints(address _who, uint _value) external returns (bool success) {
   if(_who != msg.sender) throw;
   points[_who] -= _value;
   return true;
  }
  
  function removeExtraPoints(address _who, address _manager, uint _value) external returns (bool success) {
     if(_who != msg.sender) throw;
     extraPoints[_manager][_who] -= _value;
     return true;
   }
}