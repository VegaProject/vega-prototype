/*
pragma solidity ^0.4.6;

import '../../installed_contracts/zeppelin/contracts/token/StandardToken';

// Simple Agreement for Future Equity
// Discount, no cap version
contract Safe {
  string public investor;
  uint public purchaseAmount;
  string public project;
  uint public discount;
  uint public roundPrice;
  uint public amount;

  string public name;
  string public symbol;
  uint public decimals = 18;
  string public version;
  uint public INITIAL_SUPPLY = 0;

  mapping(uint => address) public preBalances;
  mapping(uint => address) public fundBalances;

  function Safe(
    string _investor,
    uint _puchaseAmount,
    string _project,
    uint _discount,
    string _tokenName,
    string _tokenSymbol,
    string _tokneVersion
    ) {
      investor = _investor;
      purchaseAmount = _puchaseAmount;
      project = _project;
      discount = _discount;
      name = _tokenName;
      symbol = _tokenSymbol;
      version = _tokneVersion;
  }

  function setPurchasePrice(uint _roundPrice) {
    roundPrice = _roundPrice;
  }

  function buy() payable returns (uint amount) {
    uint amount = msg.value / roundPrice;
    preBalances[msg.sender] += amount;
  }

  function closeRound() {
    uint totalRaise = amount * roundPrice;
    uint fundShare = (purchaseAmount / totalRaise) * discount;
    uint addedShares = 100 - fundShare;

    fundBalances[this] += fundShare;

  }
}
*/