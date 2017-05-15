pragma solidity ^0.4.8;

import './deps/StandardToken.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './offers/Rewards.sol';
import './offers/Finders.sol';


 contract VegaToken is OutgoingMigrationTokenInterface, StandardToken {
   string public name = "Vega";
   string public symbol = "VEGA";
   uint public decimals = 18;
   string public version = "1.0";
   uint public INITIAL_SUPPLY = 12000000000000000000000000; // uint256 in wei format

   uint public constant minimumMigrationDuration = 26 weeks;
   uint public totalMigrated;

   IncomingMigrationTokenInterface public newToken;
   uint public allowOutgoingMigrationsUntilAtLeast;
   bool public allowOutgoingMigrations = false;
   address public migrationMaster;

   Rewards public rewardsContract;
   Finders public findersContract;
   

   modifier onlyFromMigrationMaster() {
     if (msg.sender != migrationMaster) throw;
     _;
   }
   uint public finders = 15;
    uint public quorum = 300;


   function VegaToken(address _migrationMaster, address _rewardsContract, address _findersContract) {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
     rewardsContract = Rewards(_rewardsContract);
     findersContract = Finders(_findersContract);
   }

   function rewardRate() public constant returns (uint rate) {
     return rewardsContract.rate();
   }

   function creatorsDeposit(uint _requestedAmount) public constant returns (uint deposit) {
     uint amount = _requestedAmount * rewardRate();
     return amount;
   }
   
   function findersPoints() public constant returns (uint finders) {
     return findersContract.finders(); 
   }




   // Migration methods
   ///---------------------------------------------------------------------------------------------------------------------------------------
   function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
     if (_master == 0) throw;
     migrationMaster = _master;
   }

   function changeRewardsContract(address _rewardsContract) onlyFromMigrationMaster external {
     if(_rewardsContract == 0) throw;
     rewardsContract = Rewards(_rewardsContract);
   }
   
   function changeFindersContract(address _findersContract) onlyFromMigrationMaster external {
       if(_findersContract == 0) throw;
       findersContract = Finders(_findersContract);
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

  


   /// ()
   ///---------------------------------------------------------------------------------------------------------------------------------------
   // just for testing as of now
   function () stoppable payable {
   }


 }
