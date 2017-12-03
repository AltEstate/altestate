import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const Crowdsale = artifacts.require("./Crowdsale.sol")
const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require("./UserRegistry.sol")

function bn (from) {
  return new web3.BigNumber(from)
}

async function setFlags (crowdsale, flags, sig) {
  const flagsMap = {
    whitelisted: 0,
    knownOnly: 1,
    amountBonus: 2,
    earlyBonus: 3,
    refundable: 4,
    tokenExcange: 5,
    allowToIssue: 6,
    extraDistribution: 7,
    mintingShipment: 8,
    cappedInEther: 9,
    pullingTokens: 10
  }

  let flagArgs = Array(Object.keys(flagsMap).length).fill().map(e => false)
  for (let key in flags) {
    if (typeof flagsMap[key] === 'undefined') {
      throw new Error(`undefined arg key: ${key}`)
    }

    flagArgs[flagsMap[key]] = true
  }

  sig = sig || {}

  crowdsale.setFlags(...flagArgs, sig)
}

contract('crowdsale', accounts => {
  let ownerSig = { from: accounts[0] }
  let buyerSig = { from: accounts[1] }
  let crowdsale, registry, token, debugHandler

  // prepare contracts to tests
  beforeEach(async () => {
    // create empty registry of users
    registry = await UserRegistry.new(ownerSig)
    // simple mintable token
    token = await DefaultToken.new("Test Token", "TST", 18, registry.address, ownerSig)

    crowdsale = await Crowdsale.new(ownerSig)
    
    debugHandler = crowdsale.Debug({}, { fromBlock: 0, toBlock: 'latest'})
    debugHandler.watch((error, result) => {
      if (error) {
        return console.error(error)
      }

      return console.log(result.args.message)
    })

    for (let index = 0; index < 3; index++) {
      await registry.addAddress(accounts[index])
    }

    await crowdsale.setToken(token.address, ownerSig)

    const time = latestTime()
    await crowdsale.setTime(time - duration.days(1), time + duration.days(30), ownerSig)
    await crowdsale.setPrice(ether(1).div(100), ownerSig)
    await crowdsale.setWallet(accounts[5], ownerSig)
    await crowdsale.setSoftHardCaps(
      ether(1e5), // soft cap is 100k
      ether(1e6)  // hard cap is 1kk
    )
    
    await token.transferOwnership(crowdsale.address, ownerSig)
  })

  afterEach(async () => {
    await debugHandler.stopWatching()
  })

  describe('setup tests', () => {
    it('should be sanable', async() => {
      await crowdsale.saneIt(ownerSig)
      let sane = await crowdsale.state()
      assert(sane.eq(1), `not ready yet? state is ${sane}`)
    })

    it('should allow to buy', async() => {
      await crowdsale.saneIt(ownerSig)
      await crowdsale.buyTokens(accounts[1], { value: ether(1), from: accounts[1] })
    })
  })
})