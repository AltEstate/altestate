import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const Crowdsale = artifacts.require("./Crowdsale.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

contract('crowdsale', () => {
  it('pass', async () => {
    
  })
})