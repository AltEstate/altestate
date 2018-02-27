pragma solidity ^0.4.18;

import "../base/TokenRecipient.sol";
import "zeppelin-solidity/contracts/token/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract ExtraHolderContract is TokenRecipient {
  using SafeMath for uint;

  mapping(address => uint) shares;
  mapping(address => uint) totalAtWithdrawal;
  address public holdingToken;
  uint public totalReceived;

  function ExtraHolderContract(
    address _holdingToken,
    address[] _recipients,
    uint[] _partions)
  public
  {
    require(_holdingToken != address(0x0));
    require(_recipients.length > 0);
    require(_recipients.length == _partions.length);

    uint ensureFullfield;

    for(uint index = 0; index < _recipients.length; index++) {
      // overflow check isn't required.. I suppose :D
      ensureFullfield = ensureFullfield + _partions[index];
      require(_partions[index] > 0);
      require(_recipients[index] != address(0x0));

      shares[_recipients[index]] = _partions[index];
    }

    holdingToken = _holdingToken;

    // Require to setup exact 100% sum of partions
    require(ensureFullfield == 10000);
  }

  function receiveApproval(
    address _from, 
    uint256 _value,
    address _token,
    bytes _extraData) 
  public 
  {
    _extraData;
    require(_token == holdingToken);
    ERC20(holdingToken).transferFrom(_from, address(this), _value);
    totalReceived = totalReceived.add(_value);
  }

  function withdraw(
    address _recipient)
  public returns (bool) 
  {
    require(shares[_recipient] > 0);
    require(totalAtWithdrawal[_recipient] < totalReceived);

    uint left = totalReceived.sub(totalAtWithdrawal[_recipient]);
    uint share = left.mul(shares[_recipient]).div(10000);
    totalAtWithdrawal[_recipient] = totalReceived;
    ERC20(holdingToken).transfer(_recipient, share);
    return true;
  }
}