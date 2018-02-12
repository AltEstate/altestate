pragma solidity ^0.4.18;

import './DefaultToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract BaseSqmToken is DefaultToken {event __CoverageBaseSqmToken(string fileName, uint256 lineNumber);
event __FunctionCoverageBaseSqmToken(string fileName, uint256 fnId);
event __StatementCoverageBaseSqmToken(string fileName, uint256 statementId);
event __BranchCoverageBaseSqmToken(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageBaseSqmToken(string fileName, uint256 branchId);
event __AssertPostCoverageBaseSqmToken(string fileName, uint256 branchId);

  function BaseSqmToken(string _name, string _ticker, uint _cap, address _registry) 
    DefaultToken(_name, _ticker, 18, _registry) 
    public
  {__FunctionCoverageBaseSqmToken('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmToken.sol',1);

    // pre mine to sale with transfer
__CoverageBaseSqmToken('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmToken.sol',12);
     __StatementCoverageBaseSqmToken('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmToken.sol',1);
mint(msg.sender, _cap);
__CoverageBaseSqmToken('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmToken.sol',13);
     __StatementCoverageBaseSqmToken('/Users/aler/crypto/altestate-3/contracts/base/BaseSqmToken.sol',2);
finishMinting();
  }
}