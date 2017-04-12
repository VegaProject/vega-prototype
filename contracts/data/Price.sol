pragma solidity ^0.4.8;

import "../deps/oraclizeAPI_0.4.sol";

contract offChainPrice is usingOraclize {
    
}

contract onChainPrice {
    
}

contract Price is offChainPrice, onChainPrice {
    
}
