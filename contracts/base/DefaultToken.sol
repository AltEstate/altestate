pragma solidity ^0.4.18;

import './TokenRecipient.sol';
import './ApproveAndCallToken.sol';
import './TokenPolicy.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract DefaultToken is MintableToken, TokenPolicy, ApproveAndCallToken {
  using SafeMath for uint;

  string public name;
  string public ticker;
  uint public decimals;
  
  function DefaultToken(string _name, string _ticker, uint _decimals, address _registry) 
    ApproveAndCallToken()
    MintableToken()
    TokenPolicy(_registry) public {
    name = _name;
    ticker = _ticker;
    decimals = _decimals;
  }

  function takeAway(address _holder, address _to) onlyOwner public returns (bool) {
    require(userRegistry.knownAddress(_holder) && !userRegistry.hasIdentity(_holder));

    uint allBalance = balances[_holder];
    balances[_to] = balances[_to].add(allBalance);
    balances[_holder] = 0;
    
    Transfer(_holder, _to, allBalance);
  }
}