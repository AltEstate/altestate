pragma solidity ^0.4.18;
contract UserRegistryInterface {
  event AddAddress(address indexed who);
  event AddIdentity(address indexed who);

  function knownAddress(address _who) public constant returns(bool);
  function hasIdentity(address _who) public constant returns(bool);
  function systemAddresses(address _to) public constant returns(bool);
}