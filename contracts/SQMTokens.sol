pragma solidity ^0.4.18;

import './base/BaseSqmToken.sol';

contract SQM1Token is BaseSqmToken {
  function SQM1Token(address _registry) BaseSqmToken("Test Square", "SQM1", 10000, 0, _registry) public {
  }
}
contract SQM2Token is BaseSqmToken {
  function SQM2Token(address _registry) BaseSqmToken("Test Square", "SQM2", 10000, 0, _registry) public {
  }
}
contract SQM3Token is BaseSqmToken {
  function SQM3Token(address _registry) BaseSqmToken("Test Square", "SQM3", 10000, 0, _registry) public {
  }
}