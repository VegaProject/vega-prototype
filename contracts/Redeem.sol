pragma solidity ^0.4.8;
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

  /// @param _vegaTokenAddr VegaToken contract address.
  function Redeem(VegaToken _vegaTokenAddr, Project _projectAddr) {
    VT = VegaToken(_vegaTokenAddr);
    Prj = Project(_projectAddr);
  }

  function newContracts(VegaToken _vegaTokenAddr, Project _projectAddr) onlyOwner {
    VT = VegaToken(_vegaTokenAddr);
    Prj = Project(_projectAddr);
  }

  function getProportionOfCurrentTotalSupply(address _who) public constant returns (uint) {
    uint amount = VT.balanceOf(_who);
    uint totalAmount = VT.totalSupply();
    uint proportion = converter(amount, amount, totalAmount);
    return proportion;
  }

  function getBalanceOfToken(address _token) public constant returns (uint) {
    uint amount = ERC20(_token).balanceOf(Prj);
    return amount;
  }


  function getBalanceForEachToken() public constant returns (uint) {
    for(uint i = 0; i < getAddressCount(); ++i) {
      uint amount = getBalanceOfToken(getAddressAtIndex(i));
   }
  }
  
}
