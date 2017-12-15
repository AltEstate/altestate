pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract NamedToken is StandardToken {
  string public name;
  string public ticker;
  uint public decimals;
  
  function NamedToken(string _name, string _ticker, uint _decimals) public {
    name = _name;
    ticker = _ticker;
    decimals = _decimals;
  }
}