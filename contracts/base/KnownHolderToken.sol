pragma solidity ^0.4.15;

import './UserRegistryInterface.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract KnownHolderToken is StandardToken {
  UserRegistryInterface public userRegistry;

  function KnownHolderToken(address registry) {
    require(registry != 0x0);
    userRegistry = UserRegistryInterface(registry);
  }

  modifier shouldBeFamiliarToTransfer(address _from) {
    require(!userRegistry.knownAddress(_from) || userRegistry.hasIdentity(_from));
    _;
  }
  function transfer(address _to, uint256 _value) shouldBeFamiliarToTransfer(msg.sender) public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldBeFamiliarToTransfer(_from) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}