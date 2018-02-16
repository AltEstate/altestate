pragma solidity ^0.4.18;

import './base/BaseAltCrowdsale.sol';

contract AltCrowdsalePhaseTwo is BaseAltCrowdsale {
  function AltCrowdsalePhaseTwo(
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

    // price 1 ETH -> 100 ALT
    uint(1 ether).div(100), 

    // start
    block.timestamp + 60 days,
    // end 
    block.timestamp + 90 days,

    // _softCap,
    0,
    // _hardCap
    15000 ether
  ) 
  public {
  } 
}

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

    // price 1 ETH -> 200 ALT
    uint(1 ether).div(200), 

    // start
    block.timestamp,
    // end 
    block.timestamp + 10 days,

    // _softCap,
    0,
    // _hardCap
    1500 ether
  ) 
  public {
  } 
} 