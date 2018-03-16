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

    // start
    block.timestamp,
    // end 
    block.timestamp + 1 days,

    // _softCap,
    0,
    // _hardCap
    100 ether
  ) 
  public {
  } 
} 

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

    // price 1 ETH -> 100000 ALT
    uint(1 ether).div(100000), 

    // start
    block.timestamp + 1 days,
    // end 
    block.timestamp + 2 days,

    // _softCap,
    0,
    // _hardCap
    15000 ether
  ) 
  public {
  } 
}