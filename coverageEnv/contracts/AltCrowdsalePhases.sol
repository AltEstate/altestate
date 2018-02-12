pragma solidity ^0.4.18;

import './base/BaseAltCrowdsale.sol';

contract AltCrowdsalePhaseTwo is BaseAltCrowdsale {event __CoverageAltCrowdsalePhaseTwo(string fileName, uint256 lineNumber);
event __FunctionCoverageAltCrowdsalePhaseTwo(string fileName, uint256 fnId);
event __StatementCoverageAltCrowdsalePhaseTwo(string fileName, uint256 statementId);
event __BranchCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId);
event __AssertPostCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId);

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
  public {__FunctionCoverageAltCrowdsalePhaseTwo('/Users/aler/crypto/altestate-3/contracts/AltCrowdsalePhases.sol',1);

    // saneIt();
  } 
}

contract AltCrowdsalePhaseOne is BaseAltCrowdsale {event __CoverageAltCrowdsalePhaseTwo(string fileName, uint256 lineNumber);
event __FunctionCoverageAltCrowdsalePhaseTwo(string fileName, uint256 fnId);
event __StatementCoverageAltCrowdsalePhaseTwo(string fileName, uint256 statementId);
event __BranchCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId);
event __AssertPostCoverageAltCrowdsalePhaseTwo(string fileName, uint256 branchId);

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
  public {__FunctionCoverageAltCrowdsalePhaseTwo('/Users/aler/crypto/altestate-3/contracts/AltCrowdsalePhases.sol',2);

    // saneIt();
  } 
} 