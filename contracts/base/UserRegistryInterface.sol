pragma solidity ^0.4.15;
contract UserRegistryInterface {
  mapping (address => bool) public addresses;
  mapping (address => bool) public identities;

  event AddAddress(address indexed who);
  event AddIdentity(address indexed who);

  function knownAddress(address _who) public constant returns(bool);
  function hasIdentity(address _who) public constant returns(bool);
}