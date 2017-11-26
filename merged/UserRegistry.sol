pragma solidity ^0.4.15;

contract UserRegistryInterface {
  mapping (address => bool) public addresses;
  mapping (address => bool) public identities;

  event AddAddress(address indexed who);
  event AddIdentity(address indexed who);

  function knownAddress(address _who) public constant returns(bool);
  function hasIdentity(address _who) public constant returns(bool);
}

contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;
    address public publisher;

    function MultiOwners() {
        owners[msg.sender] = true;
        publisher = msg.sender;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }

    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(_owner != publisher);
        require(msg.sender != _owner);

        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract UserRegistry is MultiOwners, UserRegistryInterface {
  function addAddress(address _who) onlyOwner public returns(bool) {
    require(!knownAddress(_who));
    addresses[_who] = true;
    AddAddress(_who);
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
}