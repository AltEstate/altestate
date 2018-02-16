pragma solidity ^0.4.18;

import './Crowdsale.sol';
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
      true,
      // Enable early bird bonus in crowdsale?
      // _isEarlyBonus,
      true,
      // Allow to buy tokens for another tokens?
      // _isTokenExcange,
      false,
      // Allow to issue tokens with tx hash (ex bitcoin)
      // _isAllowToIssue,
      true,
      // Should reject purchases with Ether?
      // _isDisableEther,
      false,
      // Should mint extra tokens for future distribution?
      // _isExtraDistribution,
      true,
      // Will ship token via minting? 
      // _isTransferShipment,
      false,
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
      6667 // 66.67%
    );

    setSoftHardCaps(
      _softCap, // soft
      _hardCap  // hard
    );

    // 200 ALT per 1 ETH
    setPrice(_price);
  }
}