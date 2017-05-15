pragma solidity ^0.4.8;
import './../deps/Ownable.sol';
import './../VegaToken';

contract Project is VegaToken {


  VegaToken public VT;
  mapping (address => uint) public points;
  mapping (address => uint) public extraPoints;
  Offer[] offers;

  function Project(VegaToken _vegaTokenAddr) {
    VT = VegaToken(_vegaTokenAddr);
  }

  function newVegaToken(VegaToken _vegaTokenAddr) onlyOwner {
    VT = VegaToken(_vegaTokenAddr);
  }

  struct Vote {
      bool inSupport;
      address voter;
  }

  struct Offer {
      address finder;
      bool findersCollected;
      uint creatorsDeposit;
      address recipient;
      uint requestAmount;
      address token;
      string description;
      uint openFor;
      uint creationTime;
      bool offerPassed;
      bool executed;
      uint numberOfVotes;
      bytes32 offerHash;
      Vote[] votes;
      mapping (address => bool) voted;
  }

  /// @required approve Project address to spend tokens
  /// @param _recipient Offer recipient address.
  /// @param _requestedAmount Amount of tokens.
  /// @param _token Token address, if NULL default is ETH.
  /// @param _description Description of the Offer.
  /// @param _openFor Time allowed to vote, must be under 30 days.
  /// @param _offerHash Hash of Offer.
  /// @return offerId the Id of the new Offer.
  function newOffer(
    address _recipient,
    uint _requestedAmount,
    address _token,
    string _description,
    uint _openFor,
    bytes _offerHash
    )
    onlyShareholders
    external
    returns (uint offerId)
  {
    if(VT.creatorsDeposit(_requestedAmount) > VT.balanceOf(msg.sender)) throw;
    if(_openFor < now + 7 days || _openFor > now + 30 days) throw;
    offerId = offers.length++;
    Offer o = offers[offerId];
    o.finder = msg.sender;
    o.findersCollected = false;
    VT.transferFrom(msg.sender, this, VT.creatorsDeposit(_requestedAmount));
    o.creatorsDeposit = VT.creatorsDeposit(_requestedAmount);
    o.recipient = _recipient;
    o.requestAmount = _requestedAmount;
    o.token = _token;
    o.description = _description;
    o.openFor = _openFor;
    o.creationTime = now;
    o.offerPassed = false;
    o.executed = false;
    o.numberOfVotes = 1;
    o.offerHash = sha3(_recipient, _requestedAmount, _token, _description, _openFor, _offerHash);
    Vote[] votes;
    mapping (address => bool) voted;
    return offerId;
  }

  /// @param _id Id of Offer.
    /// @param _recipient Offer recipient address.
    /// @param _requestedAmount Amount of tokens.
    /// @param _token Token address, if NULL default is ETH.
    /// @param _description Description of the Offer.
    /// @param _openFor Time allowed to vote, must be under 30 days.
    /// @param _offerHash Hash of Offer.
    /// @return codeChecksOut bool for if the hash matches.
  function checkOffer(
    uint _id,
    address _recipient,
    uint _requestedAmount,
    address _token,
    string _description,
    uint _openFor,
    bytes _offerHash
    )
    constant
    returns (bool codeChecksOut)
  {
    Offer o = offers[_id];
    return o.offerHash == sha3(_recipient, _requestedAmount, _token, _description, _openFor, _offerHash);
  }

  /// @param _id Id of Offer.
  /// @param _supportsOffer The voter's position.
  /// @return voteId Id of the vote.
  function offerVote(
    uint _id,
    bool _supportsOffer
    )
    onlyShareholders
    returns (uint voteId)
  {
    Offer o = offers[_id];
    if(o.voted[msg.sender] == true) throw;
    voteId = o.votes.length++;
    o.votes[voteId] = Vote({inSupport: _supportsOffer, voter: msg.sender});
    o.voted[msg.sender] = true;
    o.numberOfVotes = voteId + 1;
    return voteId;
  }

  function executeOffer(
    uint _id,
    bytes _transactionBytecode
    )
  {
    Offer o = offers[_id];
    if (
      now < o.openFor ||
      o.executed ||
      o.offerHash != sha3(o.recipient, requestAmount, token, description, openFor, _transactionBytecode)
      )
      throw;

    uint quorum = 0;
    uint yea = 0;
    uint nay = 0;

    for (uint i = 0; i < o.votes.length; ++i) {
      Vote v = o.votes[i];
      uint voteWeight = VT.balanceOf(v.voter);
      uint extraWeight = VT.extraWeight(v.voter);
      quorum += voteWeight;
      if(v.inSupport) {
        yea += voteWeight + extraWeight;
      } else {
        nay += voteWeight + extraWeight;
      }
    }

    quorum += o.creatorsDeposit;
    yea += o.creatorsDeposit;

    if(quorum <= VT.quorum()) {
      throw;
    } else if (yea > nay) {
      o.executed = true;
      /*if(!o.recipient.call.value(o.requestAmount * 1 ether)(transactionBytecode)) {
        throw;
      }*/ // make function that makes the mint contract able to spend the tokens, this checks for errors.
      o.offerPassed = true;
      for (uint x = 0; x < o.votes.length; x++) {
        Vote vP = o.votes[x];
        uint points = VT.balanceOf(vP.voter);
        uint fee = VT.fee(vP.voter);
        uint extraPoints = VT.totalManaged(vP.voter) - fee;
        points[vP.voter] += points + fee;
        extraPoints[vP.voter] += extraPoints;

      }
      uint finderVotingPoints = o.creatorsDeposit;
      uint findersReward = VT.finders() +  finderVotingPoints;
      points[o.finder] += findersReward;

    } else {
      o.offerPassed = false;
    }
  }



/// Helper functions

/*
  function getFinder(uint id) public constant returns (address) {
    return offers[id].finder;
  }

  function getFindersCollected(uint id) public constant returns (bool) {
    return offers[id].findersCollected;
  }

  function getRecipient(uint id) public constant returns (address) {
    return offers[id].recipient;
  }

  function getRequestAmount(uint id) public constant returns (uint) {
    return offers[id].requestAmount;
  }

  function getDescription(uint id) public constant returns (string) {
    return offers[id].description;
  }

  function getCreationTime(uint id) public constant returns (uint) {
    return offers[id].creationTime;
  }

*/
}
