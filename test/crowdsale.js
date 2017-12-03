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

  describe('setup tests', () => {
    // prepare contracts to tests
    before(async () => {
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

    after(async () => {
      await debugHandler.stopWatching()
    })

    it('should be sanable', async() => {
      await crowdsale.saneIt(ownerSig)
      let sane = await crowdsale.state()
      assert(sane.eq(1), `not ready yet? state is ${sane}`)
    })

    it('should allow to buy', async() => {
      await crowdsale.buyTokens(accounts[1], { value: ether(1), from: accounts[1] })
    })
  })

  describe('features tests', () => {
    describe('known users', () => {
      it('disallow unkown', async () => {
        assert.fail()
      })
      it('allow after add', async () => {
        assert.fail()
      })
    })

    describe('whitelisting', () => {
      it('disallow non whitelisted user', async () => {
        assert.fail()
      })
      it('allow after whitelisting', async () => {
        assert.fail()
      })
      it('reject adding without rights', async () => {
        assert.fail()
      })
      it('disallow less than min amount', async () => {
        assert.fail()
      })
      it('disallow more than max amount', async () => {
        assert.fail()
      })
      it('replace min/max amounts', async () => {
        assert.fail()
      })
    })

    describe('buy with tokens', () => {
      it('allow to buy with token', async () => {
        assert.fail()
      })
      it('change conversion rate', async () => {
        assert.fail()
      })
      it('raise wei with tokens', async () => {
        assert.fail()
      })
    })

    describe('pulling tokens', () => {
      it('reject pulling without finalization', async () => {
        assert.fail()
      })
      it('pull tokens', async () => {
        assert.fail()
      })
    })

    describe('refunding', () => {
      it('allow owner to setup extra distribution', async () => {
        assert.fail()
      })
      it('reject refunding without finalization', async () => {
        assert.fail()
      })
      it('allow refund when cap isn\'t achived', async () => {
        assert.fail()
      })
      it('disallow refund if cap is achived', async () => {
        assert.fail()
      })
      it('should transfer funds to wallet only if cap is achived', async () => {
        assert.fail()
      })
      it('allow enable refund if requires', async () => {
        assert.fail()
      })
    })

    describe('bonuses', () => {
      describe('personal bonuses', () => {
        it('allow owner to add personal bonus', async () => {
          assert.fail()
        })
        it('personal bonus should be less than 50%', async () => {
          assert.fail()
        })
        it('disallow anyone to add personal bonus', async () => {
          assert.fail()
        })
        it('personal bonus calculation', async () => {
          assert.fail()
        })
        it('referal shipment', async () => {
          assert.fail()
        })
      })

      describe('amount bonuses', () => {
        it('allow owner to add amount bonuses', async () => {
          assert.fail()
        })
        it('disallow anyone to add amount bonuses', async () => {
          assert.fail()
        })
        it('disallow to add amount bonuses after sanetize', async () => {
          assert.fail()
        })
        it('amount bonuses calculation test', async () => {
          assert.fail()
        })
      })

      describe('time bonuses', () => {
        it('allow owner to add time bonuses', async () => {
          assert.fail()
        })
        it('disallow anyone to add time bonuses', async () => {
          assert.fail()
        })
        it('disallow to add time bonuses after sanetize', async () => {
          assert.fail()
        })
        it('time bonuses calculation test', async () => {
          assert.fail()
        })
      })
    })

    describe('extra distribution', () => {
      it('allow to setup extra distribution after sanetize', async () => {
        assert.fail()
      })
      it('disallow anyone to setup', async () => {
        assert.fail()
      })
      it('reject change extra distribution after sanetize', async () => {
        assert.fail()
      })
      it('should mint extra tokens', async () => {
        assert.fail()
      })
    })

    describe('capped', () => {
      it('allow owner to setup caps', async () => {
        assert.fail()
      })
      it('disallow anyone to setup caps', async () => {
        assert.fail()
      })
      it('reject setup after sanetize', async () => {
        assert.fail()
      })
      it('reject buy when cap is achived', async () => {
        assert.fail()
      })
      it('fail crowdsale then soft cap isn\'t achived', async () => {
        assert.fail()
      })
      it('success then soft cap is achived', async () => {
        assert.fail()
      })
    })
  })
})