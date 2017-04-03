pragma solidity ^0.4.2;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { 
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData){
        Token t = Token(_token);
        if (!t.transferFrom(_from, this, _value)) throw;
        receivedTokens(_from, _value, _token, _extraData);
    }

    function () payable {
        receivedEther(msg.sender, msg.value);
    }
}

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract TimeLockMultisig is owned, tokenRecipient {

    /* Contract Variables and events */
    Proposal[] public proposals;
    uint public numProposals;
    mapping (address => uint) public memberId;
    Member[] public members;
    uint minimumTime = 10;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter, string justification);
    event ProposalExecuted(uint proposalID, int result, uint deadline);
    event MembershipChanged(address member, bool isMember);

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        bool executed;
        int currentResult;
        bytes32 proposalHash;
        uint creationDate;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Member {
        address member;
        string name;
        uint memberSince;
    }

    struct Vote {
        bool inSupport;
        address voter;
        string justification;
    }

    /* modifier that allows only shareholders to vote and create new proposals */
    modifier onlyMembers {
        if (memberId[msg.sender] == 0)
        throw;
        _;
    }

    /* First time setup */
    function TimeLockMultisig(address founder, address[] initialMembers, uint minimumAmountOfMinutes) payable {
        if (founder != 0) owner = founder;
        if (minimumAmountOfMinutes !=0) minimumTime = minimumAmountOfMinutes;
        // It’s necessary to add an empty first member
        addMember(0, ''); 
        // and let's add the founder, to save a step later       
        addMember(owner, 'founder');   
        changeMembers(initialMembers, true);     
    }

    /*make member*/
    function addMember(address targetMember, string memberName) onlyOwner {
        uint id;
        if (memberId[targetMember] == 0) {
           memberId[targetMember] = members.length;
           id = members.length++;
           members[id] = Member({member: targetMember, memberSince: now, name: memberName});
        } else {
            id = memberId[targetMember];
            Member m = members[id];
        }

        MembershipChanged(targetMember, true);
    }

    function removeMember(address targetMember) onlyOwner {
        if (memberId[targetMember] == 0) throw;

        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }

    function changeMembers(address[] newMembers, bool canVote) {
        for (uint i = 0; i < newMembers.length; i++) {
            if (canVote)
                addMember(newMembers[i], '');
            else 
                removeMember(newMembers[i]);
        }
    }

    /* Function to create a new proposal */
    function newProposal(
        address beneficiary,
        uint weiAmount,
        string jobDescription,
        bytes transactionBytecode
    )
        onlyMembers
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = weiAmount;
        p.description = jobDescription;
        p.proposalHash = sha3(beneficiary, weiAmount, transactionBytecode);
        p.executed = false;
        p.creationDate = now;
        ProposalAdded(proposalID, beneficiary, weiAmount, jobDescription);
        numProposals = proposalID+1;
        vote(proposalID, true, '');

        return proposalID;
    }

    /* Function to create a new proposal */
    function newProposalInEther(
        address beneficiary,
        uint etherAmount,
        string jobDescription,
        bytes transactionBytecode
    )
        onlyMembers
        returns (uint proposalID)
    {
        return newProposal(beneficiary, etherAmount * 1 ether, jobDescription, transactionBytecode);
    }

    /* function to check if a proposal code matches */
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint etherAmount,
        bytes transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
    }

    function vote(
        uint proposalNumber,
        bool supportsProposal,
        string justificationText
    )
        onlyMembers
        returns (uint voteID)
    {
        Proposal p = proposals[proposalNumber];         // Get the proposal
        if (p.voted[msg.sender] == true) throw;         // If has already voted, cancel
        p.voted[msg.sender] = true;                     // Set this voter as having voted
        if (supportsProposal) {                         // If they support the proposal
            p.currentResult++;                          // Increase score
        } else {                                        // If they don't
            p.currentResult--;                          // Decrease the score
        }

        // Create a log of this event
        Voted(proposalNumber,  supportsProposal, msg.sender, justificationText);

        // If you can execute it now, do it
        if ( now > proposalDeadline(proposalNumber)
            && p.currentResult > 0
            && p.proposalHash == sha3(p.recipient, p.amount, '')
            && supportsProposal) {
            executeProposal(proposalNumber, '');
        }
    }

    function proposalDeadline(uint proposalNumber) constant returns(uint deadline) {
        Proposal p = proposals[proposalNumber];
        uint factor = calculateFactor(uint(p.currentResult), (members.length - 1));
        return p.creationDate + uint(factor * minimumTime *  1 minutes);
    }

    function calculateFactor(uint a, uint b) constant returns (uint factor) {
        return 2**(20 - (20 * a)/b);
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) returns (int result) {
        Proposal p = proposals[proposalNumber];
        /* Check if the proposal can be executed:
           - Has the voting deadline arrived?
           - Has it been already executed or is it being executed?
           - Does the transaction code match the proposal?
           - Has a minimum quorum?
        */

        if (now < proposalDeadline(proposalNumber)
            || p.currentResult <= 0
            || p.executed
            || !checkProposalCode(proposalNumber, p.recipient, p.amount, transactionBytecode))
            throw;


        p.executed = true;
        if (!p.recipient.call.value(p.amount)(transactionBytecode)) {
            throw;
        }

        // Fire Events
        ProposalExecuted(proposalNumber, p.currentResult, proposalDeadline(proposalNumber));
    }
}