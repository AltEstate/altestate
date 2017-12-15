pragma solidity ^0.4.18;

import './base/Crowdsale.sol';
contract BaseAltCrowdsale is Crowdsale {
  function BaseAltCrowdsale(
    address _registry,
    address _token,
    address _extraTokensHolder,
    address _wallet,
    bool _isWhitelisted,
    uint _price,
    uint _start,
    uint _end,
    uint _softCap,
    uint _hardCap
  ) public {
    setFlags(
      // Should be whitelisted to buy tokens
      // _isWhitelisted,
      _isWhitelisted,
      // Should be known user to buy tokens
      // _isKnownOnly,
      true,
      // Enable amount bonuses in crowdsale? 
      // _isAmountBonus,
      false,
      // Enable early bird bonus in crowdsale?
      // _isEarlyBonus,
      true,
      // Allow to refund money?
      // _isRefundable,
      false,
      // Allow to buy tokens for another tokens?
      // _isTokenExcange,
      false,
      // Allow to issue tokens with tx hash (ex bitcoin)
      // _isAllowToIssue,
      true,
      // Should mint extra tokens for future distribution?
      // _isExtraDistribution,
      false,
      // Will ship token via minting? 
      // _isMintingShipment,
      true,
      // Should be capped in ether
      // bool _isCappedInEther,
      true,
      // Should check personal bonuses?
      // _isPersonalBonuses
      true,
      // Should allow to claimFunds before finalizations?
      false
    );

    setToken(_token); 
    setTime(_start, _end);
    setRegistry(_registry);
    setWallet(_wallet);
    setExtraDistribution(
      _extraTokensHolder,
      3000 // 30%
    );

    setSoftHardCaps(
      _softCap, // soft
      _hardCap  // hard
    );

    // 200 ALT per 1 ETH
    setPrice(_price);
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