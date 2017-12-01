pragma solidity ^0.4.15;

import './base/KnownHolderToken.sol';
import './base/ApproveAndCallToken.sol';
import './base/NamedToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract AltToken is NamedToken, KnownHolderToken, ApproveAndCallToken, MintableToken {
  function AltToken(address _registry) 
    NamedToken("Alt Estate", "ALT", 10)
    ApproveAndCallToken()
    MintableToken()
    KnownHolderToken(_registry) public {
  }
}