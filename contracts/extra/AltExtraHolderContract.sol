pragma solidity ^0.4.18;

import "./ExtraHolderContract.sol";

contract AltExtraHolderContract is ExtraHolderContract {
  address[] private altRecipients = [
    // Transfer two percent of all ALT tokens to bounty program participants on the day of tokens issue.
    // Final distribution will be done by our partner Bountyhive.io who will transfer coins from
    // the provided wallet to all bounty hunters community.
    address(0x84bE27E1d3AeD5e6CF40445891d3e2AB7d3d98e8),
    // Transfer eighteen percent of all ALT tokens for future network growth.
    address(0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0),
    // Transfer twenty percent of all ALT tokens for Team and Advisors remunerations.
    address(0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b)
  ];
  uint[] private altPartions = [
    500,
    4500,
    5000
  ];

  function AltExtraHolderContract(address _holdingToken)
    ExtraHolderContract(_holdingToken, altRecipients, altPartions)
    public
  {}
}