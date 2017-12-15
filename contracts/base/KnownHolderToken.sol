pragma solidity ^0.4.18;

import './UserRegistryInterface.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract KnownHolderToken is StandardToken {
  UserRegistryInterface public userRegistry;

  function KnownHolderToken(address registry) public {
    require(registry != 0x0);
    userRegistry = UserRegistryInterface(registry);
  }

  modifier shouldBeFamiliarToTransfer(address _from, address _to) {
    require(!userRegistry.knownAddress(_from) || userRegistry.hasIdentity(_from) || userRegistry.systemAddresses(_to));
    _;
  }
  function transfer(address _to, uint256 _value) shouldBeFamiliarToTransfer(msg.sender, _to) public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldBeFamiliarToTransfer(_from, _to) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}