pragma solidity ^0.4.9;

contract Math {

   function percent(uint _numerator, uint _denominator, uint _precision) public constant returns(uint quotient) {
         // caution, check safe-to-multiply here
        uint numerator  = _numerator * 10 ** (_precision+1);
        // with rounding of last digit
        uint _quotient =  ((numerator / _denominator) + 5) / 10;
        return (_quotient);
    }

   function multiplyPercentage(uint _value, uint _numerator, uint _denominator) public constant returns (uint) {
        uint value = (_value * _numerator) / _denominator;
        return value;
    }

}

contract CDR is Math {
    
 
   function returnOnDecision(uint _currentValue, uint _startingValue) public constant returns (uint) {
        uint rod = _currentValue / _startingValue;
        return rod;
    }

   function cagrCalc(uint _rod, uint _vegaPeriods) public constant returns (uint cagr) {
        cagr = _rod**(1/_vegaPeriods)-1;
        return cagr;
    }

   function rewardCalc(uint _stake, uint _cagr) public constant returns (uint reward) {
        reward = _stake * _cagr;
        return reward;
    }

   function tokensCalc(uint _rewards, uint _absTotalRewards, uint _tokenConversion) public constant returns (uint tokens) {
        tokens = multiplyPercentage(_tokenConversion, _rewards, _absTotalRewards);
        return tokens;
    }
    
   function calculateCDRForPositiveOutcome(
        uint _currentValue,
        uint _startingValue,
        uint _vegaPeriods,
        uint _stake,
        uint _absTotalRewards,
        uint _tokenConverison,
        uint _currentBalance
        ) public constant returns (uint) {
            uint ROD = returnOnDecision(_currentValue, _startingValue);
            uint CAGR = cagrCalc(ROD, _vegaPeriods);
            uint REWARD = rewardCalc(_stake, CAGR);
            uint TOKENS = tokensCalc(REWARD, _absTotalRewards, _tokenConverison);
            uint newBalance = _currentBalance + TOKENS;
            return newBalance;
    }
}