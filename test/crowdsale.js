import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const Crowdsale = artifacts.require("./Crowdsale.sol")
const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require("./UserRegistry.sol")

let crowdsale, registry, token, debugHandler, accounts,
    ownerSig, buyerSig

function bn (from) {
  return new web3.BigNumber(from)
}

function setFlags (crowdsale, flags, sig) {
  const flagsMap = {
    whitelisted: 0,
    knownOnly: 1,
    amountBonus: 2,
    earlyBonus: 3,
    refundable: 4,
    tokenExcange: 5,
    allowToIssue: 6,
    extraDistribution: 7,
    transferShipment: 8,
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

  return crowdsale.setFlags(...flagArgs, sig)
}

async function makeContext() {
  registry = await UserRegistry.new(ownerSig)
  token = await DefaultToken.new('Test Token', 'TST', 18, registry.address, ownerSig)
  crowdsale = await Crowdsale.new(ownerSig)
  debugHandler = crowdsale.Debug({}, { fromBlock: 0, toBlock: 'latest'})
  debugHandler.watch((error, result) => {
    if (error) { return console.error(error) }
    return console.log('\t\t\t\tlog: ', result.args.message)
  })

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
}


async function cleanContext() {
  await debugHandler.stopWatching()
}

contract('crowdsale', _accs => {
  accounts = _accs
  ownerSig = { from: accounts[0] }
  buyerSig = { from: accounts[1] }

  describe('setup tests', async () => {
    before(async () => await makeContext())
    after(async () => await cleanContext())
    
    it('allow owner to setup flags', async () => {
      await setFlags(crowdsale, {
        whitelisted:      true,
        knownOnly:        true,
        amountBonus:      true,
        earlyBonus:       true,
        refundable:       true,
        tokenExcange:     true,
        allowToIssue:     true,
        extraDistribution: true,
        transferShipment:  true,
        cappedInEther:    true,
        pullingTokens:    true
      }, ownerSig)

      assert(await crowdsale.isWhitelisted(), 'should be whitelisted')
      assert(await crowdsale.isKnownOnly(), 'should be known only')
      assert(await crowdsale.isAmountBonus(), 'shold be amount bonus')
      assert(await crowdsale.isRefundable(), 'should be refundable')
      assert(await crowdsale.isTokenExchange(), 'should be a token exchange')
      assert(await crowdsale.isAllowToIssue(), 'should be issue allow')
      assert(await crowdsale.isExtraDistribution(), 'should be extra distirbution')
      assert(await crowdsale.isTransferShipment(), 'should be transfer shipment')
      assert(await crowdsale.isCappedInEther(), 'should be capped in ether')
      assert(await crowdsale.isPullingTokens(), 'should be pulling tokens')
    })

    it('allow owner to resetup flags', async () => {
      await setFlags(crowdsale, {}, ownerSig);
      
      assert(!(await crowdsale.isWhitelisted()), 'shouldn\'t be whitelisted')
      assert(!(await crowdsale.isKnownOnly()), 'shouldn\'t be known only')
      assert(!(await crowdsale.isAmountBonus()), 'sholdn\'t be amount bonus')
      assert(!(await crowdsale.isRefundable()), 'shouldn\'t be refundable')
      assert(!(await crowdsale.isTokenExchange()), 'shouldn\'t be a token exchange')
      assert(!(await crowdsale.isAllowToIssue()), 'shouldn\'t be issue allow')
      assert(!(await crowdsale.isExtraDistribution()), 'shouldn\'t be extra distirbution')
      assert(!(await crowdsale.isTransferShipment()), 'shouldn\'t be transfer shipment')
      assert(!(await crowdsale.isCappedInEther()), 'shouldn\'t be capped in ether')
      assert(!(await crowdsale.isPullingTokens()), 'shouldn\'t be pulling tokens')
    })
    
    it('reject anyone to setup flags', async () => {
      await expectThrow(setFlags(crowdsale, { whitelisted: false }, buyerSig))
    })

    it('should be sanable', async() => {
      await crowdsale.saneIt(ownerSig)
      let sane = await crowdsale.state()
      console.log(sane.toString(10))
      assert(sane.eq(1), `not ready yet? state is ${sane}`)
    })
    
    it('reject setup flags after sanetize', async () => {
      await expectThrow(setFlags(crowdsale, { whitelisted: true }, ownerSig))
    })

    it('should allow to buy', async () => {
      await crowdsale.buyTokens(accounts[1], { value: ether(1), from: accounts[1] })
    })
  })

  describe('features tests', async () => {
    describe('known users', async () => {
      before(async () => await makeContext())
      after(async () => await cleanContext())
      
      it('disallow anyone to set only known', async () => {
        await expectThrow(setFlags(crowdsale, { knownOnly: true }, buyerSig))
      })

      it('allow owner to set only known beneficiaries', async () => {
        await setFlags(crowdsale, {
          knownOnly: true
        }, ownerSig)

        assert(await crowdsale.isKnownOnly(), 'should be known only')
      })

      it('reject sanetize without registry', async () => {
        await expectThrow(crowdsale.saneIt(ownerSig))
      })

      it('sanetize with registry', async () => {
        await crowdsale.setRegistry(registry.address)
        await crowdsale.saneIt(ownerSig)
      })

      it('disallow unkown', async () => {
        await expectThrow(crowdsale.buyTokens(accounts[1], { value: ether(1), from: accounts[1] }))
      })

      it('allow after add', async () => {
        await registry.addAddress(accounts[1], ownerSig)
        await crowdsale.buyTokens(accounts[1], { value: ether(1), from: accounts[1] })
      })
    })

    describe('whitelisting', async () => {
      before(async () => await makeContext())
      after(async () => await cleanContext())

      it('disallow anyone to set whitelisting', async () => {
        await expectThrow(setFlags(crowdsale, { whitelisted: true }, buyerSig))
      })

      it('allow owner to set whitelisting', async () => {
        await setFlags(crowdsale, {
          whitelisted: true
        }, ownerSig)

        assert(await crowdsale.isWhitelisted(), 'should be whitelisted')
      })


      it('disallow non whitelisted user', async () => {
        
      })
      it('allow after whitelisting', async () => {
        
      })
      it('reject adding without rights', async () => {
        
      })
      it('disallow less than min amount', async () => {
        
      })
      it('disallow more than ma amount', async () => {
        
      })
      it('replace min/max amounts', async () => {
        
      })
    })

    describe('buy with tokens', async () => {
      it('allow to buy with token', async () => {
        
      })
      it('change conversion rate', async () => {
        
      })
      it('raise wei with tokens', async () => {
        
      })
    })

    describe('pulling tokens', async () => {
      it('reject pulling without finalization', async () => {
        
      })
      it('pull tokens', async () => {
        
      })
    })

    describe('refunding', async () => {
      it('allow owner to setup extra distribution', async () => {
        
      })
      it('reject refunding without finalization', async () => {
        
      })
      it('allow refund when cap isn\'t achived', async () => {
        
      })
      it('disallow refund if cap is achived', async () => {
        
      })
      it('should transfer funds to wallet only if cap is achived', async () => {
        
      })
      it('allow enable refund if requires', async () => {
        
      })
    })

    describe('bonuses', async () => {
      describe('personal bonuses', () => {
        it('allow owner to add personal bonus', async () => {
          
        })
        it('personal bonus should be less than 50%', async () => {
          
        })
        it('disallow anyone to add personal bonus', async () => {
          
        })
        it('personal bonus calculation', async () => {
          
        })
        it('referal shipment', async () => {
          
        })
      })

      describe('amount bonuses', () => {
        it('allow owner to add amount bonuses', async () => {
          
        })
        it('disallow anyone to add amount bonuses', async () => {
          
        })
        it('disallow to add amount bonuses after sanetize', async () => {
          
        })
        it('amount bonuses calculation test', async () => {
          
        })
      })

      describe('time bonuses', () => {
        it('allow owner to add time bonuses', async () => {
          
        })
        it('disallow anyone to add time bonuses', async () => {
          
        })
        it('disallow to add time bonuses after sanetize', async () => {
          
        })
        it('time bonuses calculation test', async () => {
          
        })
      })
    })

    describe('extra distribution', async () => {
      it('allow to setup extra distribution after sanetize', async () => {
        
      })
      it('disallow anyone to setup', async () => {
        
      })
      it('reject change extra distribution after sanetize', async () => {
        
      })
      it('should mint extra tokens', async () => {
        
      })
    })

    describe('capped', async () => {
      it('allow owner to setup caps', async () => {
        
      })
      it('disallow anyone to setup caps', async () => {
        
      })
      it('reject setup after sanetize', async () => {
        
      })
      it('reject buy when cap is achived', async () => {
        
      })
      it('fail crowdsale then soft cap isn\'t achived', async () => {
        
      })
      it('success then soft cap is achived', async () => {
        
      })
    })

    describe('transfer funds', async () => {
      it('allow owner to setup wallet', async () => {
        
      })
      it('disallow anyone to setup wallet', async () => {
        
      })
      it('reject setup after sanetize', async () => {
        
      })
    })
  })
})