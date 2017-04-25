pragma solidity ^0.4.7;

contract Rewards {

  struct ProposalReward {
    uint currentReward;
    mapping(address => uint) points;
  }
  
}
