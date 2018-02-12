pragma solidity ^0.4.18;

import './Crowdsale.sol';

contract BaseSqmCrowdsale is Crowdsale {event __CoverageBaseSqmCrowdsale(string fileName, uint256 lineNumber);
event __FunctionCoverageBaseSqmCrowdsale(string fileName, uint256 fnId);
event __StatementCoverageBaseSqmCrowdsale(string fileName, uint256 statementId);
event __BranchCoverageBaseSqmCrowdsale(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageBaseSqmCrowdsale(string fileName, uint256 branchId);
event __AssertPostCoverageBaseSqmCrowdsale(string fileName, uint256 branchId);

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
  ) public {__FunctionCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',1);

__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',17);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',1);
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

__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',55);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',2);
setToken(_token); 
__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',56);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',3);
setTime(_start, _end);
__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',57);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',4);
setRegistry(_registry);
__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',58);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',5);
setWallet(_wallet);

__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',60);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',6);
setSoftHardCaps(
      _softCap, // soft
      _hardCap  // hard
    );

__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',65);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',7);
setPrice(_price);

__CoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',67);
     __StatementCoverageBaseSqmCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmCrowdsale.sol',8);
setTokenExcange(_altToken, 1 ether);
  }
}