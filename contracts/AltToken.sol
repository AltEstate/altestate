pragma solidity ^0.4.18;

import './base/DefaultToken.sol';
import './base/ApproveAndCallToken.sol';
import './base/NamedToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract AltToken is DefaultToken {
  function AltToken(address _registry) DefaultToken("Alt Estate", "ALT", 10, _registry) public {
  }
}