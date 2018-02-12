pragma solidity ^0.4.18;
import './TokenRecipient.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract ApproveAndCallToken is StandardToken {event __CoverageApproveAndCallToken(string fileName, uint256 lineNumber);
event __FunctionCoverageApproveAndCallToken(string fileName, uint256 fnId);
event __StatementCoverageApproveAndCallToken(string fileName, uint256 statementId);
event __BranchCoverageApproveAndCallToken(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageApproveAndCallToken(string fileName, uint256 branchId);
event __AssertPostCoverageApproveAndCallToken(string fileName, uint256 branchId);

  function approveAndCall(address _spender, uint _value, bytes _data) public returns (bool) {__FunctionCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',1);

__CoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',7);
     __StatementCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',1);
TokenRecipient spender = TokenRecipient(_spender);
__CoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',8);
     __StatementCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',2);
if (approve(_spender, _value)) {__BranchCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',1,0);
__CoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',9);
      spender.receiveApproval(msg.sender, _value, this, _data);
__CoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',10);
       __StatementCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',3);
return true;
    }else { __BranchCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',1,1);}

__CoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',12);
     __StatementCoverageApproveAndCallToken('/Users/aler/crypto/altestate-3/contracts/base/ApproveAndCallToken.sol',4);
return false;
  }
}