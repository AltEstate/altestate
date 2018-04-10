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

  // ERC223 Token improvement to send tokens to smart-contracts
  function transfer(address _to, uint _value) public returns (bool success) { 
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if (isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return super.transfer(_to, _value);
    }
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private view returns (bool) {
    uint length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }

  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    return approveAndCall(_to, _value, _data);
  }
}