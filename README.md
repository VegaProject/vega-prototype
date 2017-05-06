# Vega
### A Decentralized Venture Capital Funding Platform
[![Website](https://cdn-images-1.medium.com/max/119/1*S5uPPLkh3B-03lV482Ddrg@2x.png)](http://www.vega.fund)

# What is Vega?
Vega is decentralized funding organization, that creates value for investors and projects all around the globe. Vega uses Ethereum smart contract technology to operate autonomously on The Internet. Vega Core is the software which enables the interaction with the organization.

----

# Offers Overview
Offers are the proposals created by members of the fund, that determine the course of the fund.

| Offer Type  | Offer Description | Development Status |
| ------------- | ------------- | ------------- |
| project     | An offer to the fund, to fund a project of some kind. | Working |
| liquidation | An offer to liquidate one or more project offers  | Working |
| reward      | Propose an offer to implement a new reward amount for offers | Working |
| finders     | A new finders fee proposal | Working |
| mint        | A new proposal to have a second token offering | Not ready yet |
| credit      | A proposal to raise ETH using debt methods | Not ready yet |

## Offer Methods
| Method | Params | Action |
| ------------- | ------------- | ------------- |
| `newProjectProposal` | `beneficiary [address], etherAmount [uint], liquidateDate [uint], JobDescription [string], transactionBytecode [bytes]` | Creates a new project offer. |
| `checkProposalCode` | `proposalNumber [uint], beneficiary [address], etherAmount [uint], liquidateDate [uint], transactionBytecode [bytes]` | Returns boolan that determins if a sha3 hash of the offer is true or false. |
| `projectVote` | `proposalNumber [uint], supportsProposal [bool]` | Returns a `voteID`. This is how a Vega member would vote for an offer. |

----------------
# Tokens Overview
Vega Tokens are at the core of what the Vega software can provide. 
## Tokens Methods

### Balances and transfers
| Method | Params | Action |
| ------------- | ------------- | ------------- |
| `balanceOf` | `_owner [address]` | Returns the balance of given address |
| `transfer` | `_to [address], _value [uint256]` | Transfers Vega Tokens to a valid Ethereum wallet or contract address. |
| `approve` | `_spender [address], _value [uint256]` | Approves another Ethereum wallet or contract address to use functions of the Vega token on behalf of the owner. |
| `allowance` | `_owner [address], _value [uint256]` | Returns the allowence of a `_spender` for a given address |
| `transferFrom` | `_from [address], _to [address], _value [uint256]` | Trasfers tokens from another wallet or contract address that has given approval using `approve`|

### Migration methods
| Method | Params | Action |
| ------------- | ------------- | ------------- |
| `migrateToNewContract` | `_value [uint256]` | Moves tokens to a new Vega contract. |

### Reward methods
| Commands | Params | Action |
| ------------- | ------------- | ------------- |
| `rewardFinder` | `proposalID [uint256]` | Rewards the finder of a proposal (now called an "offer"). |
| `claimPointReward` | `claim [uint256]` | Calls getPoints from the Club contract, and converts to Vega Tokens at the currently established reward rate |


#### Status
- Pre Flight

---
#### Documentation
- [Build from source](https://github.com/VegaProject/wiki/wiki/Install-and-Build)

---
#### Quick start
	git clone git@github.com:VegaProject/vega.git		
	cd vega				
	npm install			
	testrpc			// do this in new terminal
	truffle compile		
	truffle build			
	truffle migrate
	npm run dev			

---
#### Resources
- [Slack](https://vega-fund.slack.com/shared_invite/MTUxOTE1MDQ2OTk5LTE0ODg5NDQ4MzItMWFhNGE1YjhhMA)
- [White Paper](https://docs.google.com/document/d/1rgMqqoE7NNTPCLEGyCSBfYW39hqAPEi0U6tS105-U3g/edit)
- [Wiki](https://github.com/VegaProject/wiki/wiki)

---
#### License
[Fair](https://github.com/VegaProject/vega/blob/master/LICENSE)

---
