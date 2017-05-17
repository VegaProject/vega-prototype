pragma solidity ^0.4.8;
import './deps/Ownable.sol';
import './VegaToken.sol';
import './offers/Project.sol';

contract Redeem is Ownable{

  VegaToken public VT;
  Project public Prj;

  /// @param _vegaTokenAddr VegaToken contract address.
  function Redeem(VegaToken _vegaTokenAddr, Project _projectAddr) {
    VT = VegaToken(_vegaTokenAddr);
    Prj = Project(_projectAddr);
  }

  /// @param _vegaTokenAddr VegaToken contract address.
  function newVegaToken(VegaToken _vegaTokenAddr) onlyOwner {
    VT = VegaToken(_vegaTokenAddr);
  }

  /// @param _projectAddr Project contract address.
  function newProject(Project _projectAddr) onlyOwner {
    Prj = Project(_projectAddr);
  }

  function converter(uint _value, uint _numer, uint _denom) public constant returns (uint) {
     uint value = (_value * _numer) / _denom;
     return value;
  }

  function getProportionOfCurrentTotalSupply(address _who) public constant returns (uint) {
    uint amount = VT.balanceOf(_who);
    uint totalAmount = VT.totalSupply;
    uint proportion = converter(amount)
    return proportion;
  }

  function getSupplyOfGivenToken(address _token) public constant returns (uint) {
    uint amount = Prj.
  }
}
