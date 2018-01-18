pragma solidity ^0.4.18;

import './base/BaseSqmToken.sol';

contract SQM1Token is BaseSqmToken {
  function SQM1Token(address _registry) BaseSqmToken("Test Square", "SQM1", 10000 * 1e18, _registry) public {
  }
}