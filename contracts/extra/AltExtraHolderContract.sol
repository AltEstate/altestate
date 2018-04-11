pragma solidity ^0.4.18;

import "./ExtraHolderContract.sol";

contract AltExtraHolderContract is ExtraHolderContract {
  address[] private altRecipients = [
    // Transfer two percent of all ALT tokens to bounty program participants on the day of tokens issue.
    // Final distribution will be done by our partner Bountyhive.io who will transfer coins from
    // the provided wallet to all bounty hunters community.
    address(0xd251D75064DacBC5FcCFca91Cb4721B163a159fc),
    // Transfer thirty eight percent of all ALT tokens for future Network Growth and Team and Advisors remunerations.
    address(0xAd089b3767cf58c7647Db2E8d9C049583bEA045A)
  ];
  uint[] private altPartions = [
    500,
    9500
  ];

  function AltExtraHolderContract(address _holdingToken)
    ExtraHolderContract(_holdingToken, altRecipients, altPartions)
    public
  {}
}
