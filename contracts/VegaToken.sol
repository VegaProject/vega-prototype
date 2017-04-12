pragma solidity ^0.4.8;

import './deps/StandardToken.sol';
import './deps/EtherDelta.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './Club.sol';

/*
 * Vega Token
 * ERC20 Token standard provided by OpenZeppelin.
 * Note: When creating this contract, it needs to know
 * the address of the Club contract. The Club contract
 * when it is created needs to know the VegaToken contract
 * address. Just simply create the VegaToken contract
 * first with a incorect Club contract address, create
 * the Club contract with the VegaToken address, then go
 * back to the VegaToken contract and perform a change
 * to add the real address of the Club to the VegaToken
 * contract.
 *
 * Idea behind stopable and migrations:
 * When state is stoped, transfer, transferFrom, payable and trade functions no longer work.
 * However migration functions still will work during a stoped state, therefore, tokens
 * could transfered to a new contract provided by the migration master.
 */

 contract VegaToken is OutgoingMigrationTokenInterface, StandardToken {
   string public name = "Vega";
   string public symbol = "VEGA";
   uint public decimals = 18;
   string public version = "VEGA-1.0";
   uint public INITIAL_SUPPLY = 12000000000000000000000000; // uint256 in wei format

   uint public constant minimumMigrationDuration = 26 weeks;
   uint public totalMigrated;

   IncomingMigrationTokenInterface public newToken;
   uint public allowOutgoingMigrationsUntilAtLeast;
   bool public allowOutgoingMigrations = false;
   address public migrationMaster;
   EtherDelta public EtherDeltaAddress;
   Club public sharesClubTokenAddress;


   modifier onlyFromMigrationMaster() {
     if (msg.sender != migrationMaster) throw;
     _;
   }

   function VegaToken(address _migrationMaster, address _etherDeltaAddress, address _clubAddress) {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
     EtherDeltaAddress = EtherDelta(_etherDeltaAddress);
     sharesClubTokenAddress = Club(_clubAddress);
   }


   function DepositAndCreateOrderProjectTokens(uint liquidationID) stoppable {
     uint volume = sharesClubTokenAddress.getTokenAmount(liquidationID);               // getting volume of tokens of the liquidation
     uint etherAmount = sharesClubTokenAddress.getEtherAmount(liquidationID);          // getting ether amount of the liquidation
     address tokenAddress = sharesClubTokenAddress.getTokenAddress(liquidationID);     // getting token address from project
     approveSelfSpender(EtherDeltaAddress, volume);                                    // this contract is approving etherDelta to spend tokens from itself, on behalf of this contract
     EtherDeltaAddress.depositToken(tokenAddress, volume);                               // depositing tokens into etherdelta, needed the approval from the line above
    // order();
   }
     //function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) {}




   // just for testing
   function () stoppable payable {
   }

   // ---------------------------------------------------------------------------------------------------------------------------------------
   // Migration methods
   //
   function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
     if (_master == 0) throw;
     migrationMaster = _master;
   }

   function changeClubAddr(address _clubAddress) onlyFromMigrationMaster external {
     if(_clubAddress == 0) throw;
     sharesClubTokenAddress = Club(_clubAddress);
   }

   function changeEtherDeltaAddr(address _etherDeltaAddress) onlyFromMigrationMaster external {
       if(_etherDeltaAddress == 0) throw;
       EtherDeltaAddress = EtherDelta(_etherDeltaAddress);
   }

   function finalizeOutgoingMigration() onlyFromMigrationMaster external {
     if (!allowOutgoingMigrations) throw;
     if (now < allowOutgoingMigrationsUntilAtLeast) throw;
     newToken.finalizeIncomingMigration();
     allowOutgoingMigrations = false;
   }

   function beginMigrationPeriod(address _newTokenAddress) onlyFromMigrationMaster external {
     if(allowOutgoingMigrations) throw;
     if (_newTokenAddress == 0) throw;
     if (newTokenAddress != 0) throw;
     newTokenAddress = _newTokenAddress;
     newToken = IncomingMigrationTokenInterface(newTokenAddress);
     allowOutgoingMigrationsUntilAtLeast = (now + minimumMigrationDuration);
     allowOutgoingMigrations = true;
   }

   function migrateToNewContract(uint _value) external {
     if (!allowOutgoingMigrations) throw;
     if (_value == 0) throw;
     balances[msg.sender] = safeSub(balances[msg.sender], _value);
     totalSupply = safeSub(totalSupply, _value);
     totalMigrated = safeAdd(totalMigrated, _value);
     newToken.migrateFromOldContract(msg.sender, _value);
     OutgoingMigration(msg.sender, _value);
   }


 }
