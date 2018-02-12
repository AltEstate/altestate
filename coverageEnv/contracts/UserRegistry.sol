pragma solidity ^0.4.18;

import './base/UserRegistryInterface.sol';
import './base/MultiOwners.sol';

contract UserRegistry is MultiOwners, UserRegistryInterface {event __CoverageUserRegistry(string fileName, uint256 lineNumber);
event __FunctionCoverageUserRegistry(string fileName, uint256 fnId);
event __StatementCoverageUserRegistry(string fileName, uint256 statementId);
event __BranchCoverageUserRegistry(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageUserRegistry(string fileName, uint256 branchId);
event __AssertPostCoverageUserRegistry(string fileName, uint256 branchId);

  mapping (address => bool) internal addresses;
  mapping (address => bool) internal identities;
  mapping (address => bool) internal system;

  function addAddress(address _who) onlyOwner public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',1);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',12);
    __AssertPreCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',1);
 __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',1);
require(!knownAddress(_who));__AssertPostCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',1);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',13);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',2);
addresses[_who] = true;
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',14);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',3);
AddAddress(_who);
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',15);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',4);
return true;
  }

  function addSystem(address _address) onlyOwner public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',2);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',19);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',5);
system[_address] = true;
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',20);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',6);
return true;
  }

  function addIdentity(address _who) onlyOwner public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',3);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',24);
    __AssertPreCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',2);
 __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',7);
require(!hasIdentity(_who));__AssertPostCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',2);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',25);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',8);
if(!addresses[_who]) {__BranchCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',3,0);
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',26);
       __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',9);
addresses[_who] = true;
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',27);
       __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',10);
AddAddress(_who);
    }else { __BranchCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',3,1);}

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',29);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',11);
identities[_who] = true;
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',30);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',12);
AddIdentity(_who);
__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',31);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',13);
return true;
  }
  
  function knownAddress(address _who) public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',4);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',35);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',14);
return addresses[_who];
  }

  function hasIdentity(address _who) public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',5);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',39);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',15);
return knownAddress(_who) && identities[_who];
  }

  function systemAddress(address _where) public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',6);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',43);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',16);
return system[_where];
  }

  function systemAddresses(address _to, address _from) public returns(bool) {__FunctionCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',7);

__CoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',47);
     __StatementCoverageUserRegistry('/Users/aler/crypto/altestate-3/contracts/UserRegistry.sol',17);
return systemAddress(_to) || systemAddress(_from);
  }
}