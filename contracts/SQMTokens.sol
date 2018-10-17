pragma solidity ^0.4.18;

import './base/BaseSqmToken.sol';

contract SQM1Token is BaseSqmToken {
  function SQM1Token(address _registry) BaseSqmToken("European Union SQM1", "SQM1", 121 * 10 ** 6, 6, _registry) public {
  }
}
contract SQM2Token is BaseSqmToken {
  function SQM2Token(address _registry) BaseSqmToken("USA SQM2", "SQM2", 120 * 10 ** 6, 6, _registry) public {
  }
}
contract SQM3Token is BaseSqmToken {
  function SQM3Token(address _registry) BaseSqmToken("Japan SQM3", "SQM3", 34 * 10 ** 6, 6, _registry) public {
  }
}
