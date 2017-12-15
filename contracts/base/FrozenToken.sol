pragma solidity ^0.4.18;

import './UserRegistryInterface.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract FrozenToken is StandardToken, Ownable {
  bool public unfrozen;
  UserRegistryInterface public frozUserRegistry;

  event Unfrezee();

  function FrozenToken(address registry) public {
    require(registry != 0x0);
    frozUserRegistry = UserRegistryInterface(registry);
  }

  function unfrezee() onlyOwner public returns (bool) {
    require(!unfrozen);
    unfrozen = true;
  }

  modifier shouldBeUnfrozen(address _from, address _to) {
    require(unfrozen || frozUserRegistry.systemAddresses(_to, _from));
    _;
  }

  function transfer(address _to, uint256 _value) shouldBeUnfrozen(msg.sender, _to) public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldBeUnfrozen(_from, _to) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}