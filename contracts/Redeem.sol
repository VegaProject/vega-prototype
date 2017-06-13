pragma solidity ^0.4.8;

/**
*
*  REDEEM IS DEPREACHATED, NEW CONTRACT WILL BE AVAILABLE SOON.
*
*/

import './deps/Ownable.sol';
import './deps/Helpers.sol';
import './VegaToken.sol';
import './deps/ERC20.sol';
import './offers/Project.sol';

contract TokenTracker {

  struct TokensHeld {
    address[] structArray;
  }

  mapping(address => TokensHeld) tokens;

  function appendAddress(address appendMe) returns (uint length) {
    return tokens[this].structArray.push(appendMe);
  }

  function getAddressCount() constant returns(uint length) {
    return tokens[this].structArray.length;
  }

  function getAddressAtIndex(uint index) constant returns(address value) {
    return tokens[this].structArray[index];
  }
}

contract Redeem is Ownable, Helpers, TokenTracker {

  VegaToken public VT;
  Project public Prj;

  mapping(address => uint) public currentBalance;
  mapping(address => mapping (address => uint)) remaining;

  /// @param _vegaTokenAddr VegaToken contract address.
  function Redeem(VegaToken _vegaTokenAddr, Project _projectAddr) {
    VT = VegaToken(_vegaTokenAddr);
    Prj = Project(_projectAddr);
  }

  function newContracts(VegaToken _vegaTokenAddr, Project _projectAddr) onlyOwner {
    VT = VegaToken(_vegaTokenAddr);
    Prj = Project(_projectAddr);
  }

  function getProportionOfCurrentTotalSupply(address _who, uint _value) public constant returns (uint) {
    uint amount = VT.balanceOf(_who);
    uint totalAmount = VT.totalSupply();
    uint proportion = converter(_value, amount, totalAmount);
    return proportion;
  }

  function getBalanceOfToken(address _token) public constant returns (uint) {
    uint amount = ERC20(_token).balanceOf(Prj);
    return amount;
  }

  function getBalanceForEachToken() public returns (bool) {
    for(uint i = 0; i < getAddressCount(); ++i) {
      uint amount = getBalanceOfToken(getAddressAtIndex(i));
      currentBalance[getAddressAtIndex(i)] = amount;
   }
   return true;
  }

  function redeemTokens(address _token, uint _value) public returns (bool) {
    getBalanceForEachToken(); // updates to the current balance of the fund.
    uint amount = getBalanceOfToken(_token);    // get the balance of the token that is being redeemed
    uint claim = getProportionOfCurrentTotalSupply(msg.sender, amount); // getting the amount of tokens the Vega holder is entitled to redeem.
    if(claim < _value) throw;                                           // throw if user is trying to redeem more than they are entitled to.
    ERC20(_token).transferFrom(Prj, msg.sender, _value);                // call the transferFrom function to move the coins from the Project Offer contract to the msg.sender, with the token value.
    remaining[msg.sender][_token] -= _value;
    return true;                                                        // return true
  }

  // next function will get the amount of tokens for each token address and convert it to the amount of tokens that a Vega holder is entitled to, by using the getProportionOfCurrentTotalSupply.

}
