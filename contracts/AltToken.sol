pragma solidity ^0.4.18;

import './base/DefaultToken.sol';

contract AltToken is DefaultToken {
  function AltToken(address _registry) DefaultToken("AltEstate DEMO token", "ALTdemo", 18, _registry) public {
  }
}
