pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Project.sol';
import './Liquidate.sol';

/*
 * Proxy Managers
 * Description: TODO
 */

contract Proxy is VegaToken {
    struct Manager {
        address account;
        bytes32 name;
        uint fee;
        bool funding;
        uint performance;
        uint timestamp;
        mapping (address => uint) subscribers;
    }
    uint numManagers;
    mapping (uint => Manager) managers;

    function newManager(bytes32 _name, uint _fee, bool _funding) returns (uint managerID) {
        managerID = numManagers++;
        managers[managerID] = Manager(msg.sender, _name, _fee, _funding, 0, now);
    }

    function fundManager(uint managerID, uint _value, address tokenAddr) external returns (bool success) {
        VegaToken v = VegaToken(tokenAddr);
        Manager m = managers[managerID];
        if(m.funding == false) throw;
        if(v.balanceOf(msg.sender) < _value) throw;
        v.tokenToManager(msg.sender, _value);                   // remove tokens from sender and curculation
        m.subscribers[msg.sender] += _value;                    // add caller to list of subscribers of the manager
        return true;
    }

    function participateAsManager(uint campaignID, uint value, uint managerID, address projectAddr, address tokenAddr) external {
        Manager m = managers[managerID];
        if(m.account != msg.sender) throw;
        Campaign c = campaigns[campaignID];
        //if(now >= c.duration) throw;                    // will deal with later, for testing just commented out
        if(balanceOf(msg.sender) < value) throw;
        c.funders[m.account] += value;
        c.amount += value;
        tokenToProject(m.account, value);
    }

   function mintPositionsFromManager(uint managerID) returns (bool success) {
      Manager m = managers[managerID];
      Liquidate l = Liquidate(liquidateAddr);
      uint value = getPayoutFromManager(managerID);                 // include fee subtraction in the project contract
      balance[msg.sender] = safeAdd(balances[msg.sender], value);
      totalSupply = safeAdd(totalSupply, value);
      Transfer(m.account, msg.sender, value);
   }

}
