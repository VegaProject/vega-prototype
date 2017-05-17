pragma solidity ^0.4.9;

/// @title Helpers contract - Helper functions.
/// @author George K. Van Hoomissen - <georgek@vega.fund>
contract Helpers {
  /// @dev Helper function used to multiply fixed point numbers with a decimal rate.
  /// @param _value Value
  /// @param _numer Numberator of fraction.
  /// @param _denom Denominator of fraction.
  function converter(uint _value, uint _numer, uint _denom) public constant returns (uint) {
   uint value = (_value * _numer) / _denom;
   return value;
  }
}
