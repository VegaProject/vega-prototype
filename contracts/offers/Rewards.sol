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
}