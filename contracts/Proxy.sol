pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Project.sol';

/*
 * Proxy Managers
 * Description: TODO
 */

contract Proxy is Project{
    struct Manager {
        address account;
        bytes32 name;
        uint fee;
        bool funding;
        uint performance;
        uint timestamp;
        address tokenAddr;
        mapping (address => uint) subscribers;
    }
    uint numManagers;
    mapping (uint => Manager) managers;

    function newManager(bytes32 _name, uint _fee, bool _funding, address _tokenAddr) returns (uint managerID) {
        managerID = numManagers++;
        managers[managerID] = Manager(msg.sender, _name, _fee, _funding, 0, now, _tokenAddr);
    }

    function fundManager(uint managerID, uint _value) external returns (bool success) {
        Manager m = managers[managerID];
        VegaToken v = VegaToken(m.tokenAddr);
        if(m.funding == false) throw;
        v.investTokens(msg.sender, _value);                   // remove tokens from sender and curculation
        m.subscribers[msg.sender] += _value;                    // add caller to list of subscribers of the manager
        return true;
    }

    function participateAsManager(uint campaignID, uint value, uint managerID, address projectAddr) external {
        Manager m = managers[managerID];
        VegaToken v = VegaToken(m.tokenAddr);
        if(m.account != msg.sender) throw;
        Campaign c = campaigns[campaignID];
        //if(now >= c.duration) throw;                    // will deal with later, for testing just commented out
        v.investTokens(m.account, value);
        c.funders[m.account] += value;
        c.amount += value;
    }

}
