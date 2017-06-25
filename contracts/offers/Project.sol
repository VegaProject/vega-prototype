pragma solidity ^0.4.8;
import { Ownable } from '../zeppelin/Ownable.sol';
import { VegaToken } from'./../VegaToken.sol';


/// @title Project Contract - Project Offer.
/// @author George K. Van Hoomissen - <georgek@vega.fund>
contract Project is Ownable {


  VegaToken public VT;
  mapping (address => uint) public points;
  mapping (address => mapping(address => uint)) public extraPoints;
  mapping (address => uint) public findersRefund;
  Offer[] offers;


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
      address recipient;
      address token;
      uint creatorsDeposit;
      uint requestAmount;
      uint openFor;
      uint creationTime;
      uint numberOfVotes;
      string description;
      bool offerPassed;
      bool executed;      
      bytes32 salt;
      Vote[] votes;
      mapping (address => bool) voted;
  }

    event OfferEvent(
        uint indexed _offerId,
        uint indexed _creatorsDeposit,
        uint indexed _senderBalance
    );

  /// @param _recipient Offer recipient address.
  /// @param _requestedAmount Amount of tokens.
  /// @param _token Token address, if NULL default is ETH.
  /// @param _description Description of the Offer.
  /// @param _openFor Time allowed to vote, must be under 30 days.
  /// @param _salt Hash of Offer.
  /// @return offerId the Id of the new Offer.
  function newOffer(
    uint _num,
    uint _den,    
    uint _requestedAmount,
    uint _openFor,
    address _recipient,
    address _token,
    string _description,
    bytes _salt
    )
    onlyShareholders
    public
    returns (uint offerId, uint creatorsDeposit, uint senderBalance)
  {
    creatorsDeposit = VT.creatorsDeposit(_requestedAmount, _num, _den);
    senderBalance = VT.balanceOf(msg.sender);
    if(creatorsDeposit > senderBalance) throw;
    // Logic here needs to include conversion to days using `* 1 days` 
    if( (_openFor * 1 days) <  7 days || (_openFor * 1 days) >  30 days ) throw;
    offerId = offers.length++;
    Offer o = offers[offerId];
    o.finder = msg.sender;
    VT.burnForDeposit(msg.sender, creatorsDeposit);
    o.creatorsDeposit = creatorsDeposit;
    o.recipient = _recipient;
    o.requestAmount = _requestedAmount;
    o.token = _token;
    o.description = _description;
    o.openFor = _openFor;
    o.creationTime = now;
    o.offerPassed = false;
    o.executed = false;
    o.numberOfVotes = 1;
    o.salt = sha3(_recipient, _requestedAmount, _token, _description, _openFor, _salt);
    OfferEvent(offerId, creatorsDeposit, senderBalance);
  }

  /// @param _id Id of Offer.
  /// @param _recipient Offer recipient address.
  /// @param _requestedAmount Amount of tokens.
  /// @param _token Token address, if NULL default is ETH.
  /// @param _description Description of the Offer.
  /// @param _openFor Time allowed to vote, must be under 30 days.
  /// @param _salt Hash of Offer.
  /// @return codeChecksOut bool for if the hash matches.
  function checkOffer(
    uint _id,
    address _recipient,
    uint _requestedAmount,
    address _token,
    string _description,
    uint _openFor,
    bytes _salt
    )
    constant
    returns (bool codeChecksOut)
  {
    Offer o = offers[_id];
    return o.salt == sha3(_recipient, _requestedAmount, _token, _description, _openFor, _salt);
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
    if ( (now - o.creationTime * 1 days)  < o.openFor * 1 days || o.executed || o.salt != sha3(o.recipient, o.requestAmount, o.token, o.description, o.openFor, _transactionBytecode)) throw;
    if (now > o.creationTime * 1 days + 30 days) throw;
    return true;
  }

  /// @param _id Id of Offer.
  function countVotes(uint _id) public constant returns (uint yes, uint no, uint total) {
    Offer o = offers[_id];
    uint quorum = 0;
    uint yea = 0;
    uint nay = 0;
    for (uint i = 0; i < o.votes.length; i++) {
      Vote v = o.votes[i];
      uint weight = VT.balanceOf(v.voter);
      // Extra weight needs to be implemented
      //uint extraWeight = VT.totalManaged(v.voter);
      uint extraWeight = 0;
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
    //Quorum not properly setup
    if(quorum <= VT.quorum()) {
          throw;
        } else 
    if (yea > nay) {
      o.executed = true;
      if(!o.recipient.call.value(o.requestAmount * 1 ether)(_transactionBytecode)) {
        //throw;
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
}
