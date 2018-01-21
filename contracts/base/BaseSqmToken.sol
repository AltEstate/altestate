pragma solidity ^0.4.18;

import './DefaultToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract BaseSqmToken is DefaultToken {
  function BaseSqmToken(string _name, string _ticker, uint _cap, address _registry) 
    DefaultToken(_name, _ticker, 18, _registry) 
    public
  {
    // pre mine to sale with transfer
    mint(msg.sender, _cap);
    finishMinting();
  }
}