pragma solidity ^0.4.18;

import './KnownHolderToken.sol';
import './ApproveAndCallToken.sol';
import './NamedToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract BaseSqmToken is NamedToken, KnownHolderToken, ApproveAndCallToken, CappedToken {
  function BaseSqmToken(string _name, string _ticker, uint _cap, address _registry) 
    KnownHolderToken(_registry)
    NamedToken(_name, _ticker, 18)
    CappedToken(_cap) 
    public
  {
    // pre mine to sale with transfer
    mint(msg.sender, _cap);
    finishMinting();
  }
}