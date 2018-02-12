pragma solidity ^0.4.18;

import './base/BaseSqmToken.sol';

contract SQM1Token is BaseSqmToken {event __CoverageSQM1Token(string fileName, uint256 lineNumber);
event __FunctionCoverageSQM1Token(string fileName, uint256 fnId);
event __StatementCoverageSQM1Token(string fileName, uint256 statementId);
event __BranchCoverageSQM1Token(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageSQM1Token(string fileName, uint256 branchId);
event __AssertPostCoverageSQM1Token(string fileName, uint256 branchId);

  function SQM1Token(address _registry) BaseSqmToken("Test Square", "SQM1", 10000 * 1e18, _registry) public {__FunctionCoverageSQM1Token('/Users/aler/crypto/altestate-3/contracts/SQM1Token.sol',1);

  }
}