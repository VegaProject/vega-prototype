pragma solidity ^0.4.8;
contract CoreOffers {
  struct Project {
    address finder;
    bool findersCollected;
    address recipient;
    uint amount;
    uint maturity;

  }

  struct Liquidation {

  }

  struct Rewards {

  }

  struct Finders {

  }

  struct Quorum {

  }

  struct Mint {

  }

  struct Reserve {

  }

  struct Credit {

  }

  struct Distribution {

  }
}

struct ProjectProposal {
    address finder;
    bool findersCollected;
    address recipient;
    uint amount;
    uint maturity;          // time at which liquidation is an option
    string description;
    uint votingDeadline;
    bool executed;
    bool proposalPassed;
    uint numberOfVotes;
    bytes32 proposalHash;
    Vote[] votes;
    mapping (address => bool) voted;
}

struct LiquidationProposal {
    uint proposalID;
    uint etherAmount;
    uint tokens;
    uint votingDeadline;
    bool executed;
    bool liquidationPassed;
    uint numberOfVotes;
    bytes32 liquidationHash;
    Vote[] votes;
    mapping (address => bool) voted;
}

struct FinderProposal {
    uint fee;
    uint votingDeadline;
    bool executed;
    bool findersPassed;
    uint numberOfVotes;
    bytes32 findersHash;
    Vote[] votes;
    mapping (address => bool) voted;
}

struct RewardProposal {
   uint reward;
   uint votingDeadline;
   bool executed;
   bool rewardsPassed;
   uint numberOfVotes;
   bytes32 rewardsHash;
   Vote[] votes;
   mapping (address => bool) voted;
}
