pragma solidity ^0.4.18;

import './Crowdsale.sol';

contract BaseSqmCrowdsale is Crowdsale {
  function BaseSqmCrowdsale(
    address _registry,
    address _token,
    address _wallet,
    address _altToken,
    uint _price,
    uint _start,
    uint _end,
    uint _softCap,
    uint _hardCap
  ) public {
    setFlags(
      // Should be whitelisted to buy tokens
      // _isWhitelisted,
      false,
      // Should be known user to buy tokens
      // _isKnownOnly,
      true,
      // Enable amount bonuses in crowdsale? 
      // _isAmountBonus,
      false,
      // Enable early bird bonus in crowdsale?
      // _isEarlyBonus,
      false,
      // Allow to buy tokens for another tokens?
      // _isTokenExcange,
      true,
      // Allow to issue tokens with tx hash (ex bitcoin)
      // _isAllowToIssue,
      false,
      // Should reject purchases with Ether?
      // _isDisableEther,
      true,
      // Should mint extra tokens for future distribution?
      // _isExtraDistribution,
      false,
      // Will ship token via minting? 
      // _isTransferShipment,
      true,
      // Should be capped in ether
      // bool _isCappedInEther,
      false,
      // Should check personal bonuses?
      // _isPersonalBonuses
      false,
      // Should allow to claimFunds before finalizations?
      false
    );

    setToken(_token); 
    setTime(_start, _end);
    setRegistry(_registry);
    setWallet(_wallet);

    setSoftHardCaps(
      _softCap, // soft
      _hardCap  // hard
    );

    setPrice(_price);

    setTokenExcange(_altToken, 1 ether);
  }
}