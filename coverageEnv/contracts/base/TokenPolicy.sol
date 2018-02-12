pragma solidity ^0.4.18;

import './UserRegistryInterface.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract TokenPolicy is StandardToken, Ownable {event __CoverageTokenPolicy(string fileName, uint256 lineNumber);
event __FunctionCoverageTokenPolicy(string fileName, uint256 fnId);
event __StatementCoverageTokenPolicy(string fileName, uint256 statementId);
event __BranchCoverageTokenPolicy(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageTokenPolicy(string fileName, uint256 branchId);
event __AssertPostCoverageTokenPolicy(string fileName, uint256 branchId);

  bool public unfrozen;
  UserRegistryInterface public userRegistry;

  function TokenPolicy(address registry) public {__FunctionCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',1);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',12);
    __AssertPreCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',1);
 __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',1);
require(registry != 0x0);__AssertPostCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',1);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',13);
     __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',2);
userRegistry = UserRegistryInterface(registry);
  }

  event Unfrezee();

  modifier shouldPassPolicy(address _from, address _to) {__FunctionCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',2);

    // KYC policy
__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',20);
    __AssertPreCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',2);
 __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',3);
require(
      !userRegistry.knownAddress(_from) || 
       userRegistry.hasIdentity(_from) || 
       userRegistry.systemAddresses(_to, _from));__AssertPostCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',2);


    // Freeze policy
__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',26);
    __AssertPreCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',3);
 __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',4);
require(unfrozen || userRegistry.systemAddresses(_to, _from));__AssertPostCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',3);


__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',28);
    _;
  }
  function transfer(address _to, uint256 _value) shouldPassPolicy(msg.sender, _to) public returns (bool) {__FunctionCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',3);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',31);
     __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',5);
return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldPassPolicy(_from, _to) public returns (bool) {__FunctionCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',4);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',35);
     __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',6);
return super.transferFrom(_from, _to, _value);
  }

  function unfrezee() onlyOwner public returns (bool) {__FunctionCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',5);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',39);
    __AssertPreCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',4);
 __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',7);
require(!unfrozen);__AssertPostCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',4);

__CoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',40);
     __StatementCoverageTokenPolicy('/Users/aler/crypto/altestate-3/contracts/base/TokenPolicy.sol',8);
unfrozen = true;
  }
}