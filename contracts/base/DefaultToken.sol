pragma solidity ^0.4.18;

import './KnownHolderToken.sol';
import './ApproveAndCallToken.sol';
import './NamedToken.sol';
import './FrozenToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract DefaultToken is NamedToken, KnownHolderToken, ApproveAndCallToken, FrozenToken, MintableToken {
  function DefaultToken(string name, string ticker, uint decimals, address _registry) 
    NamedToken(name, ticker, decimals)
    ApproveAndCallToken()
    MintableToken()
    KnownHolderToken(_registry)
    FrozenToken(_registry) public {
  }

  function takeAway(address _holder, address _to) onlyOwner public returns (bool) {
    require(userRegistry.knownAddress(_holder) && !userRegistry.hasIdentity(_holder));

    uint allBalance = balances[_holder];
    balances[_to] = balances[_to].add(allBalance);
    balances[_holder] = 0;
    
    Transfer(_holder, _to, allBalance);
  }
}