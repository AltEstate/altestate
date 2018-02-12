pragma solidity ^0.4.18;
contract UserRegistryInterface {event __CoverageUserRegistryInterface(string fileName, uint256 lineNumber);
event __FunctionCoverageUserRegistryInterface(string fileName, uint256 fnId);
event __StatementCoverageUserRegistryInterface(string fileName, uint256 statementId);
event __BranchCoverageUserRegistryInterface(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageUserRegistryInterface(string fileName, uint256 branchId);
event __AssertPostCoverageUserRegistryInterface(string fileName, uint256 branchId);

  event AddAddress(address indexed who);
  event AddIdentity(address indexed who);

  function knownAddress(address _who) public returns(bool);
  function hasIdentity(address _who) public returns(bool);
  function systemAddresses(address _to, address _from) public returns(bool);
}