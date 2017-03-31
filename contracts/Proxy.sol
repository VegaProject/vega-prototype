pragma solidity ^0.4.6;

import './VegaToken.sol';
import './Project.sol';

/*
 * Proxy Managers
 * Description: Contract for managers, while giving some one your tokens or allowing them to spend your tokens is already allowed
 * this contract provides a way for those people to charge a fee and keep a track record for their performance.
 */

contract Proxy {
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
        v.transfer(m.account, _value);                           // transfer tokens to a manager
        m.subscribers[msg.sender] += _value;                    // add caller to list of subscribers of the manager
        return true;
    }

    function participateAsManager(uint campaignID, uint value, uint managerID, address projectAddr, address tokenAddr) external {
        Manager m = managers[managerID];
        if(m.account != msg.sender) throw;                      // only the manager can participateAsManger
        Project p = Project(projectAddr);
        p.participate(campaignID, value, tokenAddr);
    }

}
