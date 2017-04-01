Add investedAddr to VegaToken constructor function
Create methods to send tokens back to participants after a project has been approved.
Remove commented stuff on VegaToken contract
- Thinking as of tonight:
- They still have incetive to do well because they are still tracked in funders[msg.sender]
- They can now trade the tokens
- Token holders can still liquidate relitive to their stake in the fund, it will not require a person in the funders[msg.sender] to liquidate.
- Option to solve the issue of funders having assets liquidated by non funders:
- could have a liquidatiion preference period where the funders[] are the only ones able to liquidate, after that period all token holders can liquidate
- within that liquidation preference period, we could have a lock up period where the tokens are held for a bit to avoid people just having pererennce and than selling their interest.
