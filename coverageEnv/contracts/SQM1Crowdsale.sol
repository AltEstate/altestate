pragma solidity ^0.4.18;

import './base/BaseSqmCrowdsale.sol';

contract SQM1Crowdsale is BaseSqmCrowdsale {event __CoverageSQM1Crowdsale(string fileName, uint256 lineNumber);
event __FunctionCoverageSQM1Crowdsale(string fileName, uint256 fnId);
event __StatementCoverageSQM1Crowdsale(string fileName, uint256 statementId);
event __BranchCoverageSQM1Crowdsale(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageSQM1Crowdsale(string fileName, uint256 branchId);
event __AssertPostCoverageSQM1Crowdsale(string fileName, uint256 branchId);

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

    // price 1 ALT -> 10 SQM
    uint(1 ether).div(10), 

    // from now
    block.timestamp,
    // to 90 days in future
    block.timestamp + 90 days,

    // _softCap,
    150 ether,
    // _hardCap
    150 ether
  ) 
  public {__FunctionCoverageSQM1Crowdsale('/Users/aler/crypto/altestate-3/contracts/SQM1Crowdsale.sol',1);

  } 
}