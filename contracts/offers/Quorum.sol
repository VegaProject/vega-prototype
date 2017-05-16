pragma solidity ^0.4.8;

contract Quorum {
    uint public quorum = 5;
      mapping (address => uint) public points;
  mapping (address => mapping(address => uint)) public extraPoints;
}