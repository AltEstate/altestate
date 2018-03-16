pragma solidity ^0.4.18;

import './base/BaseSqmToken.sol';

contract SQM1Token is BaseSqmToken {
  function SQM1Token(address _registry) BaseSqmToken("European Union SQM1t", "SQM1t", 121 * 10 ** 6, 6, _registry) public {
  }
}
contract SQM2Token is BaseSqmToken {
  function SQM2Token(address _registry) BaseSqmToken("USA SQM2t", "SQM2t", 120 * 10 ** 6, 6, _registry) public {
  }
}
contract SQM3Token is BaseSqmToken {
  function SQM3Token(address _registry) BaseSqmToken("Japan SQM2t", "SQM3t", 26 * 10 ** 6, 6, _registry) public {
  }
}