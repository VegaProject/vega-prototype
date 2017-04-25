pragma solidity ^0.4.8;

import './deps/Ownable.sol';
import './VegaToken.sol';

contract Club is Ownable, SafeMath {

    /* Contract Variables and events */
    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;

    ProjectProposal[] public projectsProposals;
    LiquidationProposal[] public liquidationsProposals;
    FinderProposal[] public findersProposals;
    RewardProposal[] public rewardsProposals;

    uint public numProjectProposals;
    uint public numLiquidationsProposals;
    uint public numFindersProposals;
    uint public numRewardsProposals;

    uint public findersFee;
    uint public reward;
    mapping(address => uint) public points;
    
    VegaToken public sharesTokenAddress;

    event ProjectProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event LiquidationProposalAdded(uint liquidationID, uint proposalID, uint amount, uint tokens);
    event FinderProposalAdded(uint findersId, uint fee);
    event RewardProposalAdded(uint rewardsId, uint reward);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, address sharesTokenAddress);

    struct Vote {
        bool inSupport;
        address voter;
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
       uint rewardsId;
       uint reward;
       uint votingDeadline;
       bool executed;
       bool rewardPassed;
       uint numberOfVotes;
       bytes32 rewardHash;
       Vote[] votes;
       mapping (address => bool) voted;
    }

    modifier onlyShareholders {
        if (sharesTokenAddress.balanceOf(msg.sender) == 0) throw;
        _;
    }

    function Club(VegaToken sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate) payable {
        changeVotingRules(sharesAddress, minimumSharesToPassAVote, minutesForDebate);
    }

    function changeVotingRules(VegaToken sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate) onlyOwner {
        sharesTokenAddress = VegaToken(sharesAddress);
        if (minimumSharesToPassAVote == 0 ) minimumSharesToPassAVote = 1;
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, sharesTokenAddress);
    }

    /// Project Proposal
    ///------------------------------------------------------------------------------------------------------------------------------

    function newProjectProposal(address beneficiary, uint etherAmount, uint liquidateDate, string JobDescription, bytes transactionBytecode) onlyShareholders returns (uint proposalID) {
        proposalID = projectsProposals.length++;
        ProjectProposal p = projectsProposals[proposalID];
        p.finder = msg.sender;
        p.recipient = beneficiary;
        p.amount = etherAmount;
        p.maturity = liquidateDate;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, etherAmount, liquidateDate, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProjectProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
        numProjectProposals = proposalID+1;

        return proposalID;
    }

    function checkProposalCode(uint proposalNumber, address beneficiary, uint etherAmount, uint liquidateDate, bytes transactionBytecode) constant returns (bool codeChecksOut) {
        ProjectProposal p = projectsProposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, liquidateDate, transactionBytecode);
    }

    function projectVote(uint proposalNumber, bool supportsProposal) onlyShareholders returns (uint voteID) {
        ProjectProposal p = projectsProposals[proposalNumber];
        if (p.voted[msg.sender] == true) throw;

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        Voted(proposalNumber,  supportsProposal, msg.sender);
        return voteID;
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) {
        ProjectProposal p = projectsProposals[proposalNumber];
        /* Check if the proposal can be executed */
        if (now < p.votingDeadline  /* has the voting deadline arrived? */
            ||  p.executed        /* has it been already executed? */
            ||  p.proposalHash != sha3(p.recipient, p.amount, p.maturity, transactionBytecode)) /* Does the transaction code match the proposal? */
            throw;

        /* tally the votes */
        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i <  p.votes.length; ++i) {
            Vote v = p.votes[i];
            uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
            quorum += voteWeight;
            if (v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }

        /* execute result */
        if (quorum <= minimumQuorum) {
            /* Not enough significant voters */
            throw;
        } else if (yea > nay ) {
            /* has quorum and was approved */
            p.executed = true;
            if (!p.recipient.call.value(p.amount * 1 ether)(transactionBytecode)) {
                throw;
            }
            p.proposalPassed = true;
            
            for (uint x = 0; x < p.votes.length; ++x) {                
                Vote vP = p.votes[x];
                uint newPoints = sharesTokenAddress.balanceOf(vP.voter);
                points[vP.voter] += newPoints;                     
            }
            
        } else {
            p.proposalPassed = false;
        }
        // Fire Events
        ProposalTallied(proposalNumber, 1, quorum, p.proposalPassed);
    }


    /// Liquidation Proposal
    ///------------------------------------------------------------------------------------------------------------------------------
    
    function newLiquidation(uint proposalID, uint etherAmount, uint tokens, bytes transactionBytecode) onlyShareholders returns (uint liquidationID) {
        
        ProjectProposal p = projectsProposals[proposalID];
        if(p.maturity > now) throw;                             // project cannot be liquidated yet.
        liquidationID = liquidationsProposals.length++;
        LiquidationProposal l = liquidationsProposals[liquidationID];
        l.proposalID = proposalID;
        l.etherAmount = etherAmount;
        l.tokens = tokens;
        l.liquidationHash = sha3(proposalID, etherAmount, tokens, transactionBytecode);
        l.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        l.executed = false;
        l.liquidationPassed = false;
        l.numberOfVotes = 0;
        LiquidationProposalAdded(liquidationID, proposalID, etherAmount, tokens);       // create event at the top
        numLiquidationsProposals = liquidationID+1;

        return liquidationID;
    }

    function checkLiquidationCode(uint liquidationNumber, uint proposalID, uint etherAmount, uint tokens, bytes transactionBytecode) constant returns (bool codeChecksOut) {
        LiquidationProposal l = liquidationsProposals[liquidationNumber];
        return l.liquidationHash == sha3(proposalID, etherAmount, tokens, transactionBytecode);
    }

    function liquidationVote(uint liquidatationNumber, bool supportsLiquidation) onlyShareholders returns (uint voteID) {
        LiquidationProposal l = liquidationsProposals[liquidatationNumber];
        if(l.voted[msg.sender] == true) throw;

        voteID = l.votes.length++;
        l.votes[voteID] = Vote({inSupport: supportsLiquidation, voter: msg.sender});
        l.voted[msg.sender] = true;
        l.numberOfVotes = voteID +1;
        Voted(liquidatationNumber, supportsLiquidation, msg.sender);
        return voteID;
    }

    function executeLiquidation(uint liquidationNumber, bytes transactionBytecode) {
        LiquidationProposal l = liquidationsProposals[liquidationNumber];
        /* Check if the liquidation can be executed */
        if (now < l.votingDeadline  /* has the voting deadline arrived? */
            || l.executed           /* has it been already executed? */
            || l.liquidationHash != sha3(l.proposalID, l.etherAmount, l.tokens, transactionBytecode)) /* Does the transaction code match the liquidation */
            throw;

        /* tally the votes */
        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i < l.votes.length; ++i) {
            Vote v = l.votes[i];
            uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
            quorum += voteWeight;
            if(v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }

        /* execute result */
        if (quorum <= minimumQuorum) {
            /* Not enough significant voters */
            throw;
        } else if (yea > nay ) {
            /* has quorum and was approved */
            l.executed = true;
            l.liquidationPassed = true;
            
            for (uint x = 0; x < l.votes.length; ++x) {                
                Vote vP = l.votes[x];
                uint newPoints = sharesTokenAddress.balanceOf(vP.voter);
                points[vP.voter] += newPoints;                     
            }
            
        } else {
            l.liquidationPassed = false;
        }
        // Fire Events
        ProposalTallied(liquidationNumber, 1, quorum, l.liquidationPassed);
    }

    
    /// Finder Proposal
    ///------------------------------------------------------------------------------------------------------------------------------

    function newFinderProposal(uint fee, bytes transactionBytecode) onlyShareholders returns (uint findersId) {
        findersId = findersProposals.length++;
        FinderProposal fP = findersProposals[findersId];
        fP.fee = fee;
        fP.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        fP.executed = false;
        fP.findersPassed = false;
        fP.numberOfVotes = 0;
        fP.findersHash = sha3(fee, transactionBytecode);
        FinderProposalAdded(findersId, fee);
        numFindersProposals = findersId+1;

        return findersId;
    }
    
    function checkFindersCode(uint findersNumber, uint fee, bytes transactionBytecode) constant returns (bool codeChecksOut) {
        FinderProposal fP = findersProposals[findersNumber];
        return fP.findersHash == sha3(fee, transactionBytecode);
    }

    function finderVote(uint findersNumber, bool supportsFindersProposal) onlyShareholders returns (uint voteID) {
        FinderProposal fP = findersProposals[findersNumber];
        if(fP.voted[msg.sender] == true) throw;

        voteID = fP.votes.length++;
        fP.votes[voteID] = Vote({inSupport: supportsFindersProposal, voter: msg.sender});
        fP.voted[msg.sender] = true;
        fP.numberOfVotes = voteID +1;
        Voted(findersNumber, supportsFindersProposal, msg.sender);
        return voteID;
    }

    function executeFindersProposal(uint findersNumber) {
        FinderProposal fP = findersProposals[findersNumber];
        /* Check if the finders proposal can be executed */
        if (now < fP.votingDeadline || fP.executed) throw;

        /* tally the votes */
        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i < fP.votes.length; ++i) {
            Vote v = fP.votes[i];
            uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
            quorum += voteWeight;
            if(v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }

        /* execute result */
        if (quorum <= minimumQuorum) {
            /* Not enough significant voters */
            throw;
        } else if (yea > nay ) {
            /* has quorum and was approved */
            fP.executed = true;
            fP.findersPassed = true;
            findersFee = fP.fee;
            
            for (uint x = 0; x < fP.votes.length; ++x) {                
                Vote vP = fP.votes[x];
                uint newPoints = sharesTokenAddress.balanceOf(vP.voter);
                points[vP.voter] += newPoints;                     
            }
            
            
        } else {
            fP.findersPassed = false;
        }
        // Fire Events
        ProposalTallied(findersNumber, 1, quorum, fP.findersPassed);
    }

    /// Reward Proposal
    ///------------------------------------------------------------------------------------------------------------------------------

    function newRewardProposal() onlyShareholders returns (uint rewardsId);

    
   
    
    /// Finders fee methods
    ///------------------------------------------------------------------------------------------------------------------------------
    
    /* Change to single functions later, not nessary rn */

    function getTokenAmount(uint liquidationID) returns (uint) {
        LiquidationProposal l = liquidationsProposals[liquidationID];
        if(l.liquidationPassed != true) throw;
        return l.tokens;
    }

    function getEtherAmount(uint liquidationID) returns (uint) {
        LiquidationProposal l = liquidationsProposals[liquidationID];
        if(l.liquidationPassed != true) throw;
        return l.etherAmount;
    }

    function getTokenAddress(uint liquidationID) constant returns (address) {
        LiquidationProposal l = liquidationsProposals[liquidationID];
        if(l.liquidationPassed != true) throw;
        ProjectProposal p = projectsProposals[l.proposalID];
        return p.recipient;
    }

    function getFinder(uint proposalID) constant returns (address) {
        ProjectProposal p = projectsProposals[proposalID];
        if(msg.sender != p.finder) throw;           // only let a finder call this function
        if(p.proposalPassed == false) throw;        // check if proposal passed
        if(p.findersCollected == true) throw;       // check if the finder has already collected
        p.findersCollected = true;                  // set the finders collection status to true
        return p.finder;
    }
    
    
    /// Points methods
    function getPoints(address addr) constant returns (uint) {
        return points[addr];
    }
    
    function removePoints(uint amount) {
        if(amount > points[msg.sender]) throw;
        points[msg.sender] -= amount;
    }
    
    
    function eligibleForRewardFromLiquidationProposal(uint liquidationID, address addr) external constant returns (bool) {
        LiquidationProposal l = liquidationsProposals[liquidationID];
        if(msg.sender != addr) throw;                 // for now only allow sender
        if(l.liquidationPassed == false) return false;  // check if the liquidation proposal passed
        if(l.collected[addr] == true) return false;           // check if the user has already collected
        if(l.voted[addr] == false) return false;        // check if the address voted
        l.collected[addr] = true;                       // the user has collected
        return true;
    }

    function eligibleForRewardFromFinderProposal(uint findersId, address addr) external constant returns (bool) {
        FinderProposal fP = findersProposals[findersId];
        if(msg.sender != addr) throw;                 // for now only allow sender
        if(fP.findersPassed == false) return false;     // check if the proposal passed
        if(fP.collected[addr] == true) return false;          // check if the user has already collected
        if(fP.voted[addr] == false) return false;       // check if the address voted
        fP.collected[addr] = true;                            // the user has collected
        return true;
    }

}
