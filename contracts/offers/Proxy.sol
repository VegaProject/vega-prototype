pragma solidity ^0.4.8;

contract Proxy {

  Proxy[] proxys;

  struct Sub {
      bool managed;
      address voter;
  }

  struct Proxy {
    address manager;
    uint fee;
    Sub[] subs;
  }
