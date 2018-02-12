pragma solidity ^0.4.18;

import './ApproveAndCallToken.sol';
import './TokenPolicy.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract DefaultToken is MintableToken, TokenPolicy, ApproveAndCallToken {event __CoverageDefaultToken(string fileName, uint256 lineNumber);
event __FunctionCoverageDefaultToken(string fileName, uint256 fnId);
event __StatementCoverageDefaultToken(string fileName, uint256 statementId);
event __BranchCoverageDefaultToken(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageDefaultToken(string fileName, uint256 branchId);
event __AssertPostCoverageDefaultToken(string fileName, uint256 branchId);

  string public name;
  string public ticker;
  uint public decimals;
  
  function DefaultToken(string _name, string _ticker, uint _decimals, address _registry) 
    ApproveAndCallToken()
    MintableToken()
    TokenPolicy(_registry) public {__FunctionCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',1);

__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',16);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',1);
name = _name;
__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',17);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',2);
ticker = _ticker;
__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',18);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',3);
decimals = _decimals;
  }

  function takeAway(address _holder, address _to) onlyOwner public returns (bool) {__FunctionCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',2);

__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',22);
    __AssertPreCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',1);
 __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',4);
require(userRegistry.knownAddress(_holder) && !userRegistry.hasIdentity(_holder));__AssertPostCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',1);


__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',24);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',5);
uint allBalance = balances[_holder];
__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',25);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',6);
balances[_to] = balances[_to].add(allBalance);
__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',26);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',7);
balances[_holder] = 0;
    
__CoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',28);
     __StatementCoverageDefaultToken('/Users/aler/crypto/altestate-3/contracts/base/DefaultToken.sol',8);
Transfer(_holder, _to, allBalance);
  }
}