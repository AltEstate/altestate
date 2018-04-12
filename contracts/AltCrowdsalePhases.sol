pragma solidity ^0.4.18;

import './base/BaseAltCrowdsale.sol';

contract demoAltCrowdsalePhaseOne is BaseAltCrowdsale {
  function demoAltCrowdsalePhaseOne (
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

    // start
    block.timestamp,
    // end 
    block.timestamp + 90 days,

    // _softCap,
    0,
    // _hardCap
    1000000 ether
  ) 
  public {
  } 
} 
