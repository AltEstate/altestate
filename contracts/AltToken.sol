pragma solidity ^0.4.15;

import './base/KnownHolderToken.sol';
import './base/ApproveAndCallToken.sol';
import './base/NamedToken.sol';
import 'zeppelin-solidity/contracts/token/CappedToken.sol';

contract AltToken is NamedToken, KnownHolderToken, ApproveAndCallToken, CappedToken {
  function AltToken(address _registry) 
    NamedToken("Alt Estate", "ALT", 10)
    ApproveAndCallToken()
    CappedToken(10 ** 12) // 100 tokens!
    KnownHolderToken(_registry) public {
  }
}