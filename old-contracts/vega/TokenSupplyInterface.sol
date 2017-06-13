pragma solidity ^0.4.7;

function mint(address _target, uint _campaignID) returns (bool success) {
  Liquidate l = Liquidate(liquidateAddr);
  uint value = l.getPayout(_campaignID);    // make value throw in the liquidate contract
  balances[_target] = safeAdd(balances[_target], value);
  totalSupply = safeAdd(totalSupply, value);
  Transfer(this, _target, value);
  return true;
}

function mintPositionsFromManager(uint managerID) returns (bool success) {
   Manager m = managers[managerID];
   Liquidate l = Liquidate(liquidateAddr);
   uint value = getPayoutFromManager(managerID);                 // include fee subtraction in the project contract
   balance[msg.sender] = safeAdd(balances[msg.sender], value);
   totalSupply = safeAdd(totalSupply, value);
   Transfer(m.account, msg.sender, value);
}

// tokenToProject & tokenToManager should be abstracted later, they are the same just for naming clarity rn.
function tokenToProject(address _target, uint _value) returns (bool success) {
  if(msg.sender != _target) throw;
  if(balances[msg.sender] < _value) throw;
  balances[_target] = safeSub(balances[_target], _value);
  totalSupply = safeSub(totalSupply, _value);
  Transfer(_target, _target, _value);
  return true;
}

function tokenToManager(address _target, uint _value) returns (bool success) {
  if(msg.sender != _target) throw;
  if(balances[msg.sender] < _value) throw;
  balances[_target] = safeSub(balances[_target], _value);
  totalSupply = safeSub(totalSupply, _value);
  Transfer(_target, _target, _value);
  return true;
}

contract TokenSupplyInterface {
  function mint(uint _campaignID) returns (bool success) {}
  function destroy(address _target, uint _value) returns (bool success) {}
}
