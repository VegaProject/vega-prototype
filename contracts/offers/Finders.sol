pragma solidity ^0.4.8;

contract Finders {
    uint public finders = 1000;
      mapping (address => uint) public points;
  mapping (address => mapping(address => uint)) public extraPoints;
}