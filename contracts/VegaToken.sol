pragma solidity ^0.4.8;

import './StandardToken.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './Liquidate.sol';

/*
 * Vega Token
 * Vega Tokens will use ERC20 Token standard provided by OpenZeppelin.
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
   address public liquidateAddr;

   modifier onlyFromMigrationMaster() {
     if (msg.sender != migrationMaster) throw;
     _;
   }

   function VegaToken(address _migrationMaster, address _liquidateAddr) {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     liquidateAddr = _liquidateAddr;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
   }

   function mint(address _target, uint _campaignID) returns (bool success) {
     Liquidate l = Liquidate(liquidateAddr);
     uint value = l.getPayout(_campaignID);    // make value throw in the liquidate contract
     balances[_target] = safeAdd(balances[_target], value);
     totalSupply = safeAdd(totalSupply, value);
     Transfer(this, _target, value);
     return true;
   }


   //
   // Migration methods
   //
   function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
     if (_master == 0) throw;
     migrationMaster = _master;
   }

   function changeLiquidateAddr(address _liquidateAddr) onlyFromMigrationMaster external {
     if(_liquidateAddr == 0) throw;
     liquidateAddr = _liquidateAddr;
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
