pragma solidity ^0.4.18;
import './TokenRecipient.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract ApproveAndCallToken is StandardToken {
  function approveAndCall(address _spender, uint _value, bytes _data) public returns (bool) {
    TokenRecipient spender = TokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _data);
      return true;
    }
    return false;
  }
}