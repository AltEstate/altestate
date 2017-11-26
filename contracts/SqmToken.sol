pragma solidity ^0.4.15;

import './base/KnownHolderToken.sol';
import './base/ApproveAndCallToken.sol';
import './base/NamedToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract SqmToken is NamedToken, KnownHolderToken, ApproveAndCallToken, CappedToken {
  function SqmToken(string _name, string _ticker, uint _decimals, uint _cap, address _registry) 
    KnownHolderToken(_registry)
    NamedToken(_name, _ticker, _decimals)
    CappedToken(_cap) 
    public
  {
  }
}