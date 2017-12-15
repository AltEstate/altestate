pragma solidity ^0.4.18;

import './base/UserRegistryInterface.sol';
import './base/MultiOwners.sol';

contract UserRegistry is MultiOwners, UserRegistryInterface {
  mapping (address => bool) internal addresses;
  mapping (address => bool) internal identities;
  mapping (address => bool) internal system;

  function addAddress(address _who) onlyOwner public returns(bool) {
    require(!knownAddress(_who));
    addresses[_who] = true;
    AddAddress(_who);
    return true;
  }

  function addSystem(address _address) onlyOwner public returns(bool) {
    system[_address] = true;
    return true;
  }

  function addIdentity(address _who) onlyOwner public returns(bool) {
    require(!hasIdentity(_who));
    if(!addresses[_who]) {
      addresses[_who] = true;
      AddAddress(_who);
    }
    identities[_who] = true;
    AddIdentity(_who);
    return true;
  }
  
  function knownAddress(address _who) public constant returns(bool) {
    return addresses[_who];
  }

  function hasIdentity(address _who) public constant returns(bool) {
    return knownAddress(_who) && identities[_who];
  }

  function systemAddresses(address _to, address _from) public constant returns(bool) {
    return system[_to] || system[_from];
  }
}