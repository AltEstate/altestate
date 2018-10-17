pragma solidity ^0.4.18;

import './base/BaseAltCrowdsale.sol';

contract AltCrowdsalePhaseOne is BaseAltCrowdsale {
  function AltCrowdsalePhaseOne (
    address _registry,
    address _token,
    address _extraTokensHolder,
    address _wallet
  )
  BaseAltCrowdsale(
    _registry,
    _token,
    _extraTokensHolder,
    _wallet,

    // Whitelisted
    false,

    // price 1 ETH -> 100000 ALT
    uint(1 ether).div(100000),

    // start - 13 Apr 2018 12:18:33 GMT
    1523621913,
    // end - 30 Jun 2018 23:59:59 GMT
    1530403199,

    // _softCap,
    2500 ether,
    // _hardCap
    7500 ether
  )
  public {
  }
} 
