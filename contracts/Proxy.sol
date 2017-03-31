pragma solidity ^0.4.6;

import './VegaToken.sol';

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
        v.approve(m.account, _value);                           // approve the manager, do not send tokens
        m.subscribers[msg.sender] += _value;                    // add caller to list of subscribers of the manager
        return true;
    }
}
