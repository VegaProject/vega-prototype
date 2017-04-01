pragma solidity ^0.4.7;

import './VegaToken.sol';
/*
 * FundOffering
 * Description: A way to raise additional capital by taking into account the tokens that have already been invested.
 * Change this and a few toher spots to getting "_investedAddr" from approved addresses function in vega token contract. First create the function in vega token contract.
*/
contract FundOffering {

    struct OfferingProposal {
        address tokenAddr;
        uint tokenPrice;
        uint votes;
        uint currentMaxMint;
    }

    uint numProposals;
    mapping (uint => OfferingProposal) offeringProposals;

    function newProposal(address _tokenAddr, address _investedAddr, uint _tokenPrice) external returns (uint proposalID) {
        VegaToken v = VegaToken(_tokenAddr);
        uint tokens = v.balanceOf(_investedAddr);
        proposalID = numProposals++;
        offeringProposals[proposalID] = OfferingProposal(_tokenAddr, _tokenPrice, 0, tokens);
    }
}

 
