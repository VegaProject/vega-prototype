pragma solidity ^0.4.8;

import './deps/StandardToken.sol';
import './OutgoingMigrationTokenInterface.sol';
import './IncomingMigrationTokenInterface.sol';
import './offers/Project.sol';
import './offers/Rewards.sol';
import './offers/Finders.sol';
import './offers/Quorum.sol';

 /// @title VegaToken contract - Vega Tokens.
 /// @author George K. Van Hoomissen - <georgek@vega.fund>
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

   function rewardRate() public constant returns (uint numerator, uint denominator) {
    uint one = rewardsContract.numerator();
    uint two = rewardsContract.denominator();
    return (one, two);
   }

   function creatorsDeposit(uint _requestedAmount) public constant returns (uint deposit) {
     var (num, den) = rewardRate();
     uint amount = converter(_requestedAmount, num, den);
     return amount;
   }

   function finders() public constant returns (uint finders) {
     return findersContract.currentFinders();
   }

   function quorum() public constant returns (uint quorum) {
    return quorumContract.currentQuorum();
   }

   // Helper function used to multiply fixed point numbers with a decimal rate.
   function converter(uint _value, uint _numer, uint _denom) public constant returns (uint) {
    uint value = (_value * _numer) / _denom;
    return value;
   }

   function burnForDeposit(address _who, uint _value) external returns (bool success) {
     if(_who != msg.sender) throw;
     uint amount = balances[_who];
     if(amount < _value) throw;
     balances[_who] = safeSub(balances[_who], _value);
     return true;
   }

  function collectFindersFee(address _who, uint _value) public returns (bool success) {
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

   function convertProjectPoints(uint _value) public returns (bool success) {
     uint amount = getProjectOfferPoints(msg.sender);
     if(amount < _value) throw;
     projectContract.removePoints(msg.sender, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertProjectExtraPoints(uint _value, address _manager) public returns (bool success) {
     uint amount = getProjectOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     projectContract.removeExtraPoints(msg.sender, _manager, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertRewardsPoints(uint _value) public returns (bool success) {
     uint amount = getRewardsOfferPoints(msg.sender);
     if(amount < _value) throw;
     rewardsContract.removePoints(msg.sender, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertRewardsExtraPoints(uint _value, address _manager) public returns (bool success) {
     uint amount = getRewardsOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     rewardsContract.removeExtraPoints(msg.sender, _manager, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertFindersPoints(uint _value) public returns (bool success) {
     uint amount = getFindersOfferPoints(msg.sender);
     if(amount < _value) throw;
     findersContract.removePoints(msg.sender, _value);
     var (num, den) = rewardRate();
     uint tokens = converter(_value, num, den);
     balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
     totalSupply = safeAdd(totalSupply, tokens);
     return true;
   }

   function convertFindersExtraPoints(uint _value, address _manager) public returns (bool success) {
     uint amount = getFindersOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     findersContract.removeExtraPoints(msg.sender, _manager, _value);
     var (num, den) = rewardRate();
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

   function convertQuorumExtraPoints(uint _value, address _manager) public returns (bool success) {
     uint amount = getQuorumOfferExtraPoints(msg.sender, _manager);
     if(amount < _value) throw;
     quorumContract.removeExtraPoints(msg.sender, _manager, _value);
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




   /// ()
   ///---------------------------------------------------------------------------------------------------------------------------------------
   // just for testing as of now
   function () payable {
   }


 }
