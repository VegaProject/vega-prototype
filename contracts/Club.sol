pragma solidity ^0.4.8;

import './deps/Ownable.sol';
import './VegaToken.sol';

contract Club is Ownable {

    /* Contract Variables and events */
    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    Proposal[] public proposals;
    Liquidation[] public liquidations;
    uint public numProposals;
    uint public numLiquidations;
    //token public sharesTokenAddress;
    VegaToken public sharesTokenAddress;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event LiquidationAdded(uint liquidationID, uint proposalID, uint amount, uint tokens);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, address sharesTokenAddress, address trader);
    
    struct Proposal {
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
    
    struct Liquidation {
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

    struct Vote {
        bool inSupport;
        address voter;
    }

    /* modifier that allows only shareholders to vote and create new proposals */
    modifier onlyShareholders {
        if (sharesTokenAddress.balanceOf(msg.sender) == 0) throw;
        _;
    }

    /* First time setup */
    function Club(VegaToken sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate, address trader) payable {
        changeVotingRules(sharesAddress, minimumSharesToPassAVote, minutesForDebate, trader);
    }

    /*change rules*/
    function changeVotingRules(VegaToken sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate, address trader) onlyOwner {
        sharesTokenAddress = VegaToken(sharesAddress);
        if (minimumSharesToPassAVote == 0 ) minimumSharesToPassAVote = 1;
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        trader = trader;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, sharesTokenAddress, trader);
    }

    /* Function to create a new proposal */
    function newProposal(
        address beneficiary,
        uint etherAmount,
        uint liquidateDate,
        string JobDescription,
        bytes transactionBytecode
    ) onlyShareholders returns (uint proposalID) {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = etherAmount;
        p.maturity = liquidateDate;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, etherAmount, liquidateDate, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
        numProposals = proposalID+1;

        return proposalID;
    }
    
    function newLiquidation(
        uint proposalID,
        uint etherAmount,
        uint tokens,
        bytes transactionBytecode
    ) onlyShareholders returns (uint liquidationID) {
        
        liquidationID = liquidations.length++;
        Liquidation l = liquidations[liquidationID];
        l.proposalID = proposalID;
        l.etherAmount = etherAmount;
        l.tokens = tokens;
        l.liquidationHash = sha3(proposalID, etherAmount, tokens, transactionBytecode);
        l.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        l.executed = false;
        l.liquidationPassed = false;
        l.numberOfVotes = 0;
        LiquidationAdded(liquidationID, proposalID, etherAmount, tokens);       // create event at the top
        numLiquidations = liquidationID+1;

        return liquidationID;
    }

    /* function to check if a proposal code matches */
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint etherAmount,
        uint liquidateDate,
        bytes transactionBytecode
    ) constant returns (bool codeChecksOut) {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, liquidateDate, transactionBytecode);
    }
    
    function checkLiquidationCode(
        uint liquidationNumber,
        uint proposalID,
        uint etherAmount,
        uint tokens,
        bytes transactionBytecode
    ) constant returns (bool codeChecksOut) {
        Liquidation l = liquidations[liquidationNumber];
        return l.liquidationHash == sha3(proposalID, etherAmount, tokens, transactionBytecode);
    }

    /* */
    function vote(uint proposalNumber, bool supportsProposal) onlyShareholders returns (uint voteID) {
        Proposal p = proposals[proposalNumber];
        if (p.voted[msg.sender] == true) throw;

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        Voted(proposalNumber,  supportsProposal, msg.sender);
        return voteID;
    }
    
    function liquidateVote(uint liquidatationNumber, bool supportsLiquidation) onlyShareholders returns (uint voteID) {
        Liquidation l = liquidations[liquidatationNumber];
        if(l.voted[msg.sender] == true) throw;
        
        voteID = l.votes.length++;
        l.votes[voteID] = Vote({inSupport: supportsLiquidation, voter: msg.sender});
        l.voted[msg.sender] = true;
        l.numberOfVotes = voteID +1;
        Voted(liquidatationNumber, supportsLiquidation, msg.sender);
        return voteID;
    }
    
    function executeProposal(uint proposalNumber, bytes transactionBytecode) {
        Proposal p = proposals[proposalNumber];
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
        } else {
            p.proposalPassed = false;
        }
        // Fire Events
        ProposalTallied(proposalNumber, 1, quorum, p.proposalPassed);
    }
    
    function executeLiquidation(uint liquidationNumber, bytes transactionBytecode) {
        Liquidation l = liquidations[liquidationNumber];
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
        } else {
            l.liquidationPassed = false;
        }
        // Fire Events
        ProposalTallied(liquidationNumber, 1, quorum, l.liquidationPassed);
    }

    /* Change to one function later, not nessary rn */
    
    function getTokenAmount(uint liquidationID) returns (uint) {
        Liquidation l = liquidations[liquidationID];
        if(l.executed != true) throw;
        return l.tokens;
    }
    
    function getEtherAmount(uint liquidationID) returns (uint) {
        Liquidation l = liquidations[liquidationID];
        if(l.executed != true) throw;
        return l.etherAmount;
    }
    
    function getTokenAddress(uint liquidationID) constant returns (address) {
        Liquidation l = liquidations[liquidationID];
        if(l.executed != true) throw;
        Proposal p = proposals[l.proposalID];
        return p.recipient;
    }
}