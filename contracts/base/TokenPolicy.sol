pragma solidity ^0.4.18;

import './UserRegistryInterface.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract TokenPolicy is StandardToken, Ownable {
  bool public unfrozen;
  UserRegistryInterface public userRegistry;

  function TokenPolicy(address registry) public {
    require(registry != 0x0);
    userRegistry = UserRegistryInterface(registry);
  }

  event Unfrezee();

  modifier shouldPassPolicy(address _from, address _to) {
    // KYC policy
    require(
      !userRegistry.knownAddress(_from) || 
       userRegistry.hasIdentity(_from) || 
       userRegistry.systemAddresses(_to, _from));

    // Freeze policy
    require(unfrozen || userRegistry.systemAddresses(_to, _from));

    _;
  }
  function transfer(address _to, uint256 _value) shouldPassPolicy(msg.sender, _to) public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldPassPolicy(_from, _to) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function unfrezee() onlyOwner public returns (bool) {
    require(!unfrozen);
    unfrozen = true;
  }
}