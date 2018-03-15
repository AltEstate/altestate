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

    // price 1 ETH -> 1 SQM
    uint(1 ether), 
    // from now
    block.timestamp,
    // to 90 days in future
    block.timestamp + 90 days,

    // soft cap
    ERC20Basic(_token).totalSupply(),
    // hard cap
    ERC20Basic(_token).totalSupply()
  ) 
  public {
  } 
}

contract SQM2Crowdsale is BaseSqmCrowdsale {
  function SQM2Crowdsale(
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

    // price 1 ETH -> 1 SQM
    uint(1 ether), 

    // from now
    block.timestamp,
    // to 90 days in future
    block.timestamp + 90 days,

    // soft cap
    ERC20Basic(_token).totalSupply(),
    // hard cap
    ERC20Basic(_token).totalSupply()
  ) 
  public {
  } 
}

contract SQM3Crowdsale is BaseSqmCrowdsale {
  function SQM3Crowdsale(
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

    // price 1 ETH -> 1 SQM
    uint(1 ether), 

    // from now
    block.timestamp,
    // to 90 days in future
    block.timestamp + 90 days,

    // soft cap
    ERC20Basic(_token).totalSupply(),
    // hard cap
    ERC20Basic(_token).totalSupply()
  ) 
  public {
  } 
}