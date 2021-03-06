pragma solidity ^0.4.8;
import { Ownable } from '../zeppelin/Ownable.sol';
import { VegaToken } from'./../VegaToken.sol';

/// @title Rewards contract - Rewards Offer.
/// @author George K. Van Hoomissen - <georgek@vega.fund>
contract Rewards is Ownable {

    VegaToken public VT;
    mapping (address => uint) public points;
    mapping (address => mapping(address => uint)) public extraPoints;
    Offer[] offers;

    uint public numerator;
    uint public denominator;

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

    struct Vote {
      bool inSupport;
      address voter;
    }

    struct Offer {
      uint numerator;
      uint denominator;
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

    /// @param _numerator Numberator of fraction.
    /// @param _denominator Denominator of fraction.
    /// @param _description Description of the Offer.
    /// @param _openFor Time allowed to vote, must be under 30 days.
    /// @param _offerHash Hash of Offer.
    /// @return offerId the Id of the new Offer.
    function newOffer(
      uint _numerator,
      uint _denominator,
      string _description,
      uint _openFor,
      bytes _offerHash
      )
      onlyShareholders
      returns (uint offerId)
    {
      //if(_openFor < now + 7 days || _openFor > now + 30 days) throw;
      offerId = offers.length++;
      Offer o = offers[offerId];
      o.numerator = _numerator;
      o.denominator = _denominator;
      o.description = _description;
      o.openFor = _openFor;
      o.creationTime = now;
      o.offerPassed = false;
      o.executed = false;
      o.numberOfVotes = 1;
      o.offerHash = sha3(_numerator, _denominator, _description, _openFor, _offerHash);
      return offerId;
    }

    /// @param _id Id of Offer.
    /// @param _numerator Numerator of fraction.
    /// @param _denominator Denominator of fraction.
    /// @param _openFor Time allowed to vote, must be under 30 days.
    /// @param _offerHash Hash of Offer.
    /// @return codeChecksOut True if the hash matches.
    function checkOffer(
      uint _id,
      uint _numerator,
      uint _denominator,
      string _description,
      uint _openFor,
      bytes _offerHash
      )
      constant
      returns (bool codeChecksOut)
    {
      Offer o = offers[_id];
      return o.offerHash == sha3(_numerator, _denominator, _description, _openFor, _offerHash);
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
      if (now < o.openFor || o.executed || o.offerHash != sha3(o.numerator, o.denominator, o.description, o.openFor, _transactionBytecode)) throw;
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
        numerator = o.numerator;
        denominator = o.denominator;
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
      } else {
        o.offerPassed = false;
      }
    }

  }
