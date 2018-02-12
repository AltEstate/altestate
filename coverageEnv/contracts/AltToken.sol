pragma solidity ^0.4.18;

import './base/DefaultToken.sol';

contract AltToken is DefaultToken {event __CoverageAltToken(string fileName, uint256 lineNumber);
event __FunctionCoverageAltToken(string fileName, uint256 fnId);
event __StatementCoverageAltToken(string fileName, uint256 statementId);
event __BranchCoverageAltToken(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageAltToken(string fileName, uint256 branchId);
event __AssertPostCoverageAltToken(string fileName, uint256 branchId);

  function AltToken(address _registry) DefaultToken("Alt Estate", "ALT", 18, _registry) public {__FunctionCoverageAltToken('/Users/aler/crypto/altestate-3/contracts/AltToken.sol',1);

  }
}