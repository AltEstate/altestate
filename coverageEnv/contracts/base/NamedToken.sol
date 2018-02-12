pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract NamedToken is StandardToken {event __CoverageNamedToken(string fileName, uint256 lineNumber);
event __FunctionCoverageNamedToken(string fileName, uint256 fnId);
event __StatementCoverageNamedToken(string fileName, uint256 statementId);
event __BranchCoverageNamedToken(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageNamedToken(string fileName, uint256 branchId);
event __AssertPostCoverageNamedToken(string fileName, uint256 branchId);

  string public name;
  string public ticker;
  uint public decimals;
  
  function NamedToken(string _name, string _ticker, uint _decimals) public {__FunctionCoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',1);

__CoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',11);
     __StatementCoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',1);
name = _name;
__CoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',12);
     __StatementCoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',2);
ticker = _ticker;
__CoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',13);
     __StatementCoverageNamedToken('/Users/aler/crypto/altestate-3/contracts/base/NamedToken.sol',3);
decimals = _decimals;
  }
}