pragma solidity ^0.4.8;
import './../deps/Ownable.sol';
import './../VegaToken.sol';


/// @title Project Contract - Project Offer.
/// @author George K. Van Hoomissen - <georgek@vega.fund>
contract Project is Ownable {


  VegaToken public VT;
  mapping (address => uint) public points;
  mapping (address => mapping(address => uint)) public extraPoints;
  mapping (address => uint) public findersRefund;
  Offer[] offers;

  /// @param _vegaTokenAddr VegaToken contract address.
  function Project(VegaToken _vegaTokenAddr) {
    VT = VegaToken(_vegaTokenAddr);
  }

  /// @param _vegaTokenAddr VegaToken contract address.
  function newVegaToken(VegaToken _vegaTokenAddr) onlyOwner {
    VT = VegaToken(_vegaTokenAddr);
  }

  modifier onlyShareholders {
        if (VT.balanceOf(msg.sender) == 0) throw;
        _;
    }

  function removePoints(address _who, uint _value) external returns (bool success) {
   if(_who != msg.sender) throw;
   points[_who] -= _value;
   return true;
  }

  function removeExtraPoints(address _who, address _manager, uint _value) external returns (bool success) {
     if(_who != msg.sender) throw;
     extraPoints[_manager][_who] -= _value;
     return true;
   }

   function removeFindersFee(address _who, uint _value) external returns (bool success) {
     if(_who != msg.sender) throw;
     findersRefund[_who] -= _value;
     return true;
   }

  struct Vote {
      bool inSupport;
      address voter;
  }

  struct Offer {
      address finder;
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
    returns (uint offerId)
  {
    if(VT.creatorsDeposit(_requestedAmount) > VT.balanceOf(msg.sender)) throw;
    //if(_openFor < now + 7 days || _openFor > now + 30 days) throw;
    offerId = offers.length++;
    Offer o = offers[offerId];
    o.finder = msg.sender;
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

  /// @param _id Id of Offer.
  /// @param _transactionBytecode Hash of the Offer.
  function checkIfOfferCanExecute(uint _id, bytes _transactionBytecode) private constant returns (bool) {
    Offer o = offers[_id];
    if (now < o.openFor || o.executed || o.offerHash != sha3(o.recipient, o.requestAmount, o.token, o.description, o.openFor, _transactionBytecode)) throw;
    if (now > o.creationTime + 30 days) throw;
    return true;
  }

  /// @param _id Id of Offer.
  function countVotes(uint _id) private returns (uint yes, uint no, uint total) {
    Offer o = offers[_id];
    uint quorum = 0;
    uint yea = 0;
    uint nay = 0;
    for (uint i = 0; i < o.votes.length; i++) {
      Vote v = o.votes[i];
      uint weight = VT.balanceOf(v.voter);
      uint extraWeight = VT.totalManaged(v.voter);
      quorum += weight + extraWeight;
      if(v.inSupport) {
        yea += weight + extraWeight;
      } else {
        nay += weight + extraWeight;
      }
    }
    quorum += o.creatorsDeposit;
    yea += o.creatorsDeposit;
    return (yea, nay, quorum);
  }

  /// @param _id Id of Offer.
  /// @param _transactionBytecode Hash of Offer.
  function executeOffer(
    uint _id,
    bytes _transactionBytecode
    )
  {
    checkIfOfferCanExecute(_id, _transactionBytecode);
    var (yea, nay, quorum) = countVotes(_id);

    Offer o = offers[_id];

    if(quorum <= VT.quorum()) {
      throw;
    } else if (yea > nay) {
      o.executed = true;
      if(!o.recipient.call.value(o.requestAmount * 1 ether)(_transactionBytecode)) {
        throw;
      }

      o.offerPassed = true;
      for (uint x = 0; x < o.votes.length; x++) {
        Vote vP = o.votes[x];
        uint numPoints = VT.balanceOf(vP.voter);
        uint fee = VT.feeAmount(vP.voter);
        points[vP.voter] += numPoints + fee;
        for(uint iXX = 0; iXX < VT.getItemsInManagedArr(); iXX++) {
          extraPoints[vP.voter][VT.getSingleItemInMangedArr(iXX)] += VT.managedWeight(VT.getSingleItemInMangedArr(iXX), vP.voter) - fee;
        }
      }
      uint finderVotingPoints = o.creatorsDeposit;
      uint findersReward = VT.finders() +  finderVotingPoints;
      points[o.finder] += findersReward;
      findersRefund[o.finder] += o.creatorsDeposit;

    } else {
      o.offerPassed = false;
    }
  }

  function getOfferStatus(uint _id) public constant returns (bool, uint, address) {
    Offer o = offers[_id];
    return(o.offerPassed, o.creatorsDeposit, o.finder);
  }

  function () payable {}

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
