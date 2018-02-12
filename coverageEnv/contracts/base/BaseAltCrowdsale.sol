pragma solidity ^0.4.18;

import './Crowdsale.sol';
contract BaseAltCrowdsale is Crowdsale {event __CoverageBaseAltCrowdsale(string fileName, uint256 lineNumber);
event __FunctionCoverageBaseAltCrowdsale(string fileName, uint256 fnId);
event __StatementCoverageBaseAltCrowdsale(string fileName, uint256 statementId);
event __BranchCoverageBaseAltCrowdsale(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageBaseAltCrowdsale(string fileName, uint256 branchId);
event __AssertPostCoverageBaseAltCrowdsale(string fileName, uint256 branchId);

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
  ) public {__FunctionCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',1);

__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',17);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',1);
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
      false,
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
      false,
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

__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',55);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',2);
setToken(_token); 
__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',56);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',3);
setTime(_start, _end);
__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',57);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',4);
setRegistry(_registry);
__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',58);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',5);
setWallet(_wallet);
__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',59);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',6);
setExtraDistribution(
      _extraTokensHolder,
      3000 // 30%
    );

__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',64);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',7);
setSoftHardCaps(
      _softCap, // soft
      _hardCap  // hard
    );

    // 200 ALT per 1 ETH
__CoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',70);
     __StatementCoverageBaseAltCrowdsale('/Users/aler/crypto/altestate-3/contracts/base/BaseAltCrowdsale.sol',8);
setPrice(_price);
  }
}