pragma solidity ^0.4.15;

import './base/Crowdsale.sol';

contract AltCrowdsalePhaseOne is Crowdsale {
  function AltCrowdsalePhaseOne(
    address _registry,
    address _token,
    address _extraTokensHolder,
    uint _extraTokensPart,
    uint[] _timeSlices,
    uint[] _timePrices
  ) public
  {
    setFlags(
      // Should be whitelisted to buy tokens
      // _isWhitelisted,
      true,
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
      // Should beneficiaries pull their tokens? 
      // _isPullingTokens
      false,
      // Should check personal bonuses?
      // _isPersonalBonuses
      true
    );

    setToken(_token); 
 
    setTime(block.timestamp - 1 seconds, block.timestamp + 30 days);

    setRegistry(_registry);
    setWallet(msg.sender);
    setExtraDistribution(_extraTokensHolder, _extraTokensPart);

    setSoftHardCaps(
      5 ether, // soft
      10 ether  // hard
    );

    // 200 ALT per 1 ETH
    setPrice(uint(1 ether).div(100));

    setTimeBonuses(_timeSlices, _timePrices);
  }  
} 