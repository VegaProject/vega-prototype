pragma solidity ^0.4.8;

import "./zeppelin/token/StandardToken.sol";

import "./zeppelin/Stoppable.sol";


import './deps/Helpers.sol';
import './deps/ds-auth.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import { Project } from   './offers/Project.sol';
import { Rewards } from   './offers/Rewards.sol';
import { Finders } from './offers/Finders.sol';
import { Quorum } from  './offers/Quorum.sol';
pragma solidity ^0.4.8;

 /// @title VegaToken contract - Vega Tokens.
 /// @author George K. Van Hoomissen - <georgek@vega.fund>
 contract VegaToken is DSAuth, OutgoingMigrationTokenInterface, StandardToken, Helpers {
    // Port from 'StandardToken'
    mapping (address => mapping (address => uint)) managed;
    mapping (address => uint) fee;
    mapping (address => uint) public totalManaged;
    address[] public managedArr;
    bool public  stopped;

    modifier stoppable {
      assert (!stopped);
      _;
    }

    function stop() auth {
      stopped = true;
    }

    function start() auth {
      stopped = false;
    }

   string public name = "Vega";
   string public symbol = "VEGA";
   uint public decimals = 18;
   string public version = "1.0";
   uint public INITIAL_SUPPLY = 12000000000000000000000000; // uint256 in wei format
   uint public totalSupply = INITIAL_SUPPLY;
   uint public constant minimumMigrationDuration = 26 weeks;
   uint public totalMigrated;

   IncomingMigrationTokenInterface public newToken;
   uint public allowOutgoingMigrationsUntilAtLeast;
   bool public allowOutgoingMigrations = false;
   address public migrationMaster;
   mapping (address => uint) public totalPoints;

   Project public projectContract;
   Rewards public rewardsContract;
   Finders public findersContract;
   Quorum public quorumContract;


   modifier onlyFromMigrationMaster() {
     if (msg.sender != migrationMaster) throw;
     _;
   }

   /// @dev Creates VegaTokens.
   /// @param _migrationMaster Migration Master.
   /// @param _projectContract Project Offer contract.
   /// @param _rewardsContract Rewards Offer contract.
   /// @param _findersContract Finders Offer contract.
   /// @param _quorumContract Quorum Offer contract.
   function VegaToken(
    address _migrationMaster,
    address _projectContract,
    address _rewardsContract,
    address _findersContract,
    address _quorumContract
    )
   {
     if (_migrationMaster == 0) throw;
     migrationMaster = _migrationMaster;
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
     projectContract = Project(_projectContract);
     rewardsContract = Rewards(_rewardsContract);
     findersContract = Finders(_findersContract);
     quorumContract = Quorum(_quorumContract);
   }


   /**
    * Offer State
   **/
   /* This function doesn't perform as expected; numerator and denominator are
      both set as elements of *individual* offers not of the Rewards solution on large
      
   function rewardRate() public constant returns (uint numerator, uint denominator) {
    numerator = rewardsContract.numerator();
    denominator = rewardsContract.denominator();
   }
   */

   function creatorsDeposit(uint _requestedAmount, uint num, uint den) public constant returns (uint amount) {
     amount = converter(_requestedAmount, num, den);
   }

   function finders() public constant returns (uint finders) {
     return findersContract.currentFinders();
   }

   function quorum() public constant returns (uint quorum) {
    quorum =  totalSupply / 2;
   }

   function burnForDeposit(address _who, uint _value) external returns (bool) {
     // Similar check needs to me re-implemented but this doesn't work
     //if(_who != msg.sender) throw;
     uint amount = balances[_who];
     if(amount < _value) throw;
     balances[_who] = safeSub(balances[_who], _value);
     return true;
   }
   
  function collectFindersFee(address _who, uint _value) public returns (bool) {
    uint amount = projectContract.findersRefund(_who);
    if(amount < _value) throw;
    projectContract.removeFindersFee(_who, _value);
    balances[_who] = safeAdd(balances[_who], _value);
    return true;
   }

   /**
    * Offer Points
   **/

   function getProjectOfferPoints(address _who) private constant returns (uint points) {
    uint amount = projectContract.points(_who);
    return amount;
   }

   function getProjectOfferExtraPoints(address _who, address _from) private constant returns (uint extraPoints) {
     uint amount = projectContract.extraPoints(_from, (_who));
     return amount;
   }

   function getRewardsOfferPoints(address _who) private constant returns (uint points) {
    uint amount = rewardsContract.points(_who);
    return amount;
   }

   function getRewardsOfferExtraPoints(address _who, address _from) private constant returns (uint extraPoints) {
     uint amount = rewardsContract.extraPoints(_from, (_who));
     return amount;
   }

   function getFindersOfferPoints(address _who) private constant returns (uint points) {
    uint amount = findersContract.points(_who);
    return amount;
   }

   function getFindersOfferExtraPoints(address _who, address _from) private constant returns (uint extraPoints) {
     uint amount = findersContract.extraPoints(_from, (_who));
     return amount;
   }

   function getQuorumOfferPoints(address _who) private constant returns (uint points) {
     uint amount = quorumContract.points(_who);
     return amount;
   }

   function getQuorumOfferExtraPoints(address _who, address _from) private constant returns (uint extraPoints) {
     uint amount = quorumContract.extraPoints(_from, (_who));
     return amount;
   }


   /**
    * Offer Point Conversion
   **/

   // TODO FINISH ADDING REMOVE POINTS AND REMOVE EXTRA POINTS FUNCTIONS TO THE REST OF THE OFFERS.

   function convertProjectPoints(uint _value, uint num, uint den) public returns (bool) {
     uint amount = getProjectOfferPoints(msg.sender);
     if(amount < _value) throw;
     projectContract.removePoints(msg.sender, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertProjectExtraPoints(uint _value, address _manager, uint num, uint den) public returns (bool) {
     uint amount = getProjectOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     projectContract.removeExtraPoints(msg.sender, _manager, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertRewardsPoints(uint _value, uint num, uint den) public returns (bool) {
     uint amount = getRewardsOfferPoints(msg.sender);
     if(amount < _value) throw;
     rewardsContract.removePoints(msg.sender, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertRewardsExtraPoints(uint _value, address _manager, uint num, uint den) public returns (bool) {
     uint amount = getRewardsOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     rewardsContract.removeExtraPoints(msg.sender, _manager, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertFindersPoints(uint _value, uint num, uint den) public returns (bool) {
     uint amount = getFindersOfferPoints(msg.sender);
     if(amount < _value) throw;
     findersContract.removePoints(msg.sender, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertFindersExtraPoints(uint _value, address _manager, uint num, uint den) public returns (bool) {
     uint amount = getFindersOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     findersContract.removeExtraPoints(msg.sender, _manager, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertQuorumPoints(uint _value, uint num, uint den) public returns (bool) {
     uint amount = getQuorumOfferPoints(msg.sender);
     if(amount < _value) throw;
     quorumContract.removePoints(msg.sender, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertQuorumExtraPoints(uint _value, address _manager, uint num, uint den) public returns (bool) {
     uint amount = getQuorumOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     quorumContract.removeExtraPoints(msg.sender, _manager, _value);
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertQuorumPoints(uint _value) public returns (bool success) {
     uint amount = getQuorumOfferPoints(msg.sender);
     if(amount < _value) throw;
     quorumContract.removePoints(msg.sender, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   /**
    * Migrations
   **/

   function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
     if (_master == 0) throw;
     migrationMaster = _master;
   }

   function changeProjectContract(address _projectContract) onlyFromMigrationMaster external {
     if(_projectContract == 0) throw;
     projectContract = Project(_projectContract);
   }

   function changeRewardsContract(address _rewardsContract) onlyFromMigrationMaster external {
     if(_rewardsContract == 0) throw;
     rewardsContract = Rewards(_rewardsContract);
   }

   function changeFindersContract(address _findersContract) onlyFromMigrationMaster external {
     if(_findersContract == 0) throw;
     findersContract = Finders(_findersContract);
   }

   function changeQuorumContract(address _quorumContract) onlyFromMigrationMaster external {
     if(_quorumContract == 0) throw;
     quorumContract = Quorum(_quorumContract);
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

     function forward(address _proxy, uint _value) returns (bool) {
    managed[msg.sender][_proxy] = _value;
    managedArr.push(msg.sender);
    totalManaged[_proxy] = safeAdd(totalManaged[_proxy], _value);
    return true;
  }
  
  function getItemsInManagedArr() constant returns (uint items) {
    return managedArr.length;
  }
  
  function getSingleItemInMangedArr(uint _item) constant returns (address) {
    return managedArr[_item];
  }

  function backward(address _who, uint _value) returns (bool) {
    managed[_who][msg.sender] = _value;
    totalManaged[msg.sender] = safeSub(totalManaged[msg.sender], _value);
  }

  function managedWeight(address _owner, address _manager) constant returns (uint) {
    return managed[_owner][_manager];
  }

  function setFee(uint _fee) returns (bool) {
    fee[msg.sender] = _fee;
    return true;
  }

  function feeAmount(address _who) constant returns (uint) {
    if(totalManaged[_who] > 0) throw;
    return fee[_who];
  }

  function approveSelfSpender(address _spender, uint _value) returns (bool) {
    allowed[this][_spender] = _value;
    Approval(this, _spender, _value);
    return true;
  }



   /// ()
   ///---------------------------------------------------------------------------------------------------------------------------------------
   // just for testing as of now
   function () payable {
   }


 }
