pragma solidity ^0.4.8;

contract Finders {
    uint public finders = 1000;
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