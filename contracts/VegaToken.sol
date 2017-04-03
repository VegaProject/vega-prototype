pragma solidity ^0.4.8;

import './deps/StandardToken.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './Club.sol';

/*
 * Vega Token
 * ERC20 Token standard provided by OpenZeppelin.
 Note: When tokens are send to the investedAddr, that amount has been invested, and now the fund has
 the ability to sell those tokens to raise additional capital
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
   address public clubAddress;
   Club public sharesClubTokenAddress;
   
   uint id = Club.liquidations[0];
   
   modifier onlyFromMigrationMaster() {
     if (msg.sender != migrationMaster) throw;
     _;
   }

   function VegaToken(address _migrationMaster, address _clubAddress) {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
     sharesClubTokenAddress = Club(clubAddress);
   }
   
   function SellProjectTokens(uint liquidationID) {
      uint volume = Club.getTokenAmount(liquidationID);
      uint etherAmount = Club.getEtherAmount(liquidationID);
      /* use the volume and etherAmount above to deposit, make trade offer, and withdrawl from ether delta
   }
   

   // just for testing
   function () payable {
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
     clubAddress = _clubAddress;
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
