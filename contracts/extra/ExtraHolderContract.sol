pragma solidity ^0.4.18;

contract ExtraHolderContract is TokenRecipient {
  address public holdingToken;

  mapping(address => uint) shares;
  mapping(address => uint) totalAtWithdrawal;
  uint public totalReceived;

  function ExtraHolderContract(
    address _holdingToken,
    address[] _receipients,
    uint[] _partions
  ) {
    require(_holdingToken != address(0x0));
    require(_receipients.length > 0);
    require(_receipients.length == _partions.length);

    uint ensureFullfield;

    for(uint index = 0; index < _receipients.length; index++) {
      // overflow check isn't required.. I suppose :D
      ensureFullfield = ensureFullfield + _partions[index];
      require(_partions[index] > 0);
      require(_receipients[index] != address(0x0));

      shares[_receipients[index]] = _partions[index];
    }

    // Require to setup exact 100% sum of partions
    require(ensureFullfield == 10000);
  }

  function receiveApproval(
    address _from, 
    uint256 _value,
    address _token,
    bytes _extraData) 
  public {
    require(_token == holdingToken);

    ERC20(_token).transferFrom(_from, address(this), _value);
    totalReceived = totalReceived.add(_value);
  }
}