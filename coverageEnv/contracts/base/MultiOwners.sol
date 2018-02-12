pragma solidity ^0.4.18;

contract MultiOwners {event __CoverageMultiOwners(string fileName, uint256 lineNumber);
event __FunctionCoverageMultiOwners(string fileName, uint256 fnId);
event __StatementCoverageMultiOwners(string fileName, uint256 statementId);
event __BranchCoverageMultiOwners(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageMultiOwners(string fileName, uint256 branchId);
event __AssertPostCoverageMultiOwners(string fileName, uint256 branchId);


    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;
    address public publisher;

    function MultiOwners() public {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',1);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',12);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',1);
owners[msg.sender] = true;
__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',13);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',2);
publisher = msg.sender;
    }

    modifier onlyOwner() {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',2);
 
__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',17);
        __AssertPreCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',1);
 __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',3);
require(owners[msg.sender] == true);__AssertPostCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',1);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',18);
        _; 
    }

    function isOwner() public returns (bool) {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',3);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',22);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',4);
return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) public returns (bool) {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',4);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',26);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',5);
return owners[maybe_owner] ? true : false;
    }

    function grant(address _owner) onlyOwner public {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',5);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',30);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',6);
owners[_owner] = true;
__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',31);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',7);
AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner public {__FunctionCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',6);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',35);
        __AssertPreCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',2);
 __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',8);
require(_owner != publisher);__AssertPostCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',2);

__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',36);
        __AssertPreCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',3);
 __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',9);
require(msg.sender != _owner);__AssertPostCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',3);


__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',38);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',10);
owners[_owner] = false;
__CoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',39);
         __StatementCoverageMultiOwners('/Users/aler/crypto/altestate-3/contracts/base/MultiOwners.sol',11);
AccessRevoke(_owner);
    }
}
