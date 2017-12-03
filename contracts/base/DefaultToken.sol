pragma solidity ^0.4.15;

import './KnownHolderToken.sol';
import './ApproveAndCallToken.sol';
import './NamedToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract DefaultToken is NamedToken, KnownHolderToken, ApproveAndCallToken, MintableToken {
  function DefaultToken(string name, string ticker, uint decimals, address _registry) 
    NamedToken(name, ticker, decimals)
    ApproveAndCallToken()
    MintableToken()
    KnownHolderToken(_registry) public {
  }
}