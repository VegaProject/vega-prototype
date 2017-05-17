pragma solidity ^0.4.8;

import './deps/Ownable.sol';
import './deps/Helpers.sol';
import './VegaToken.sol';
import './offers/Project.sol';

contract Redeem is Ownable, Helpers {

  VegaToken public VT;
  Project public Prj;
  
  address[] public heldTokens;


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
  
  function getProportionOfCurrentTotalSupply(address _who) public constant returns (uint) {
    uint amount = VT.balanceOf(_who);
    uint totalAmount = VT.totalSupply();
    uint proportion = converter(amount, amount, totalAmount);
    return proportion;
  }

}
