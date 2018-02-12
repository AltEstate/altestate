pragma solidity ^0.4.18;

contract TokenRecipient {event __CoverageTokenRecipient(string fileName, uint256 lineNumber);
event __FunctionCoverageTokenRecipient(string fileName, uint256 fnId);
event __StatementCoverageTokenRecipient(string fileName, uint256 statementId);
event __BranchCoverageTokenRecipient(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageTokenRecipient(string fileName, uint256 branchId);
event __AssertPostCoverageTokenRecipient(string fileName, uint256 branchId);

  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; 
}