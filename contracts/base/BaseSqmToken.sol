pragma solidity ^0.4.18;

import './DefaultToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract BaseSqmToken is DefaultToken {
  function BaseSqmToken(string _name, string _ticker, uint _cap, uint _decimals, address _registry) 
    DefaultToken(_name, _ticker, _decimals, _registry) 
    public
  {
    // pre mine to sale with transfer
    mint(msg.sender, _cap);
    finishMinting();
  }
}