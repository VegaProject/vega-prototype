pragma solidity ^0.4.6;

import './VegaToken';

/*
 *   Proxy voting contract, vote forwarding stuff
 *
 */

contract Proxy {
    struct Manager {

    }
    uint numManagers;
    mapping (uint => Manager) managers;
}
