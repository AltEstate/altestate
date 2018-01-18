pragma solidity ^0.4.18;

import './base/BaseSqmCrowdsale.sol';

contract SQM1Crowdsale is BaseSqmCrowdsale {
  function SQM1Crowdsale(
    address _registry,
    address _token,
    address _wallet,
    address _altToken
  )
  BaseSqmCrowdsale(
    _registry,
    _token,
    _wallet,
    _altToken,

    // price 10 ALT -> 1 SQM
    uint(10 ether).div(1), 

    // from now
    block.timestamp,
    // to 90 days in future
    block.timestamp + 90 days,

    // _softCap,
    150 ether,
    // _hardCap
    150 ether
  ) 
  public {
  } 
}