pragma solidity ^0.4.8;

import '../installed_contracts/zeppelin/contracts/token/StandardToken.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './Project';

/*
 * Vega Token
 * Vega Tokens will use ERC20 Token standard provided by OpenZeppelin.
 */

 contract VegaToken is OutgoingMigrationTokenInterface, StandardToken {
   string public name = "Vega";
   string public symbol = "VEGA";
   uint public decimals = 18;
   string public version = "VEGA1.0";
   uint public INITIAL_SUPPLY = 12000000;

   uint public constant minimumMigrationDuration = 26 weeks;
   uint public totalMigrated;

   IncomingMigrationTokenInterface public newToken;
   uint public allowOutgoingMigrationsUntilAtLeast;
   bool public allowOutgoingMigrations = false;
   address public migrationMaster;
   address public liquidation;

   modifier onlyFromMigrationMaster() {
    if (msg.sender != migrationMaster) throw;
    _;
  }

  modifier onlyFromLiquidate() {
    if (msg.sender != liquidation) throw;
      _;
  }

   function VegaToken(address _migrationMaster, address _liquidation) {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     liquidation = _liquidation;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
   }

   function getBalance(address _account) returns (uint) {
       return balances[_account];
   }

   function getFundWeiBalance() returns (uint) {
     return this.balance;
   }

   function mint(address target, uint value) onlyFromLiquidate returns (bool success){
       mint(target, value);
   }

   //
   // Migration methods
   //

   function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
     if (_master == 0) throw;
     migrationMaster = _master;
   }

   function changeLiquidation(address _liquidation) onlyFromMigrationMaster external {
       if(_liquidation == 0) throw;
       liquidation = _liquidation;
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
