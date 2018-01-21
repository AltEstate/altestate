import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const Crowdsale = artifacts.require('./Crowdsale.sol')
const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

let crowdsale, registry, token, debugHandler, accounts,
    ownerSig, buyerSig

function bn (from) {
  return new web3.BigNumber(from)
}

function tokens(n) {
  return ether(n)
}

function tokensWithBonus(n, b) {
  return tokens(n).mul(b).div(10000).add(tokens(n))
}

function numberToBytearray(long, size) {
  // we want to represent the input as a 8-bytes array
  const byteArray = Array(size).fill(0);

  for (let index = byteArray.length - 1; index >= 0; index-- ) {
      let byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) / 256 ;
  }

  return byteArray;
}
function toHex(bytes) {
  let out = '0x'
  for (let index = 0; index < bytes.length; index++) {
    let byte = bytes[index]
    out += ('00' + (byte & 0xFF).toString(16)).slice(-2)
  }
  
  return out
}

function toBytes(bn) {
  return toHex(numberToBytearray(bn.toNumber(), 32))
}

function hexToBytes(hexString) {
  let out = []
  for(let index = 2; index < hexString.length; index += 2) {
    out.push(`0x${hexString[index]}${hexString[index+1]}`)
  }

  return out
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
    disableEther: 7,
    extraDistribution: 8,
    transferShipment: 9,
    cappedInEther: 10,
    personalBonuses: 11,
    allowClaimBeforeFinalization: 12
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
  if (crowdsale.Debug) {
    debugHandler = crowdsale.Debug({}, { fromBlock: 0, toBlock: 'latest'})
    debugHandler.watch((error, result) => {
      if (error) { return console.error(error) }
      return console.log('\t\t\t\tlog: ', result.args.message)
    })
  }

  await registry.addSystem(crowdsale.address, ownerSig)
  await crowdsale.setToken(token.address, ownerSig)

  const time = latestTime()
  await crowdsale.setTime(time - duration.days(1), time + duration.days(30), ownerSig)
  await crowdsale.setPrice(ether(1).div(10), ownerSig) // 1 eth -> 10 tokens
  await crowdsale.setWallet(accounts[5], ownerSig)
  await crowdsale.setSoftHardCaps(
    tokens(1e5), // soft cap is 100k
    tokens(1e6)  // hard cap is 1kk
  )  
  await token.transferOwnership(crowdsale.address, ownerSig)
}


async function cleanContext() {
  if (debugHandler) {
    await debugHandler.stopWatching()
  }
}

contract('crowdsale', (_accs) => {
  accounts = _accs
  ownerSig = { from: accounts[0] }
  buyerSig = { from: accounts[1] }

  describe('features tests', async () => {
    describe('refunding', async () => {
      let anotherToken

      before(makeContext)
      after(cleanContext)

      it('disallow anyone to setup refunding', async () => {
        await expectThrow(setFlags(crowdsale, { refundable: true }, buyerSig))
      })
      it('allow owner to setup refundable crowdsale', async () => {
        anotherToken = await DefaultToken.new('Extra Token A', 'EXC', 18, registry.address, ownerSig)
        await anotherToken.mint(buyerSig.from, 1e6 * 1e18, ownerSig)
        await setFlags(crowdsale, { refundable: true, tokenExcange: true, }, ownerSig)
        await crowdsale.setTokenExcange(anotherToken.address, ether(1), ownerSig)
        await crowdsale.saneIt()

        // buy 10 tokens with Ether
        await crowdsale.buyTokens(buyerSig.from, Object.assign({ value: ether(1) }, buyerSig))

        // buy 10 tokens with another token
        await anotherToken.approveAndCall(crowdsale.address, 1e18, toBytes(bn(1e18)), buyerSig)

        const buyerBalance = await token.balanceOf(buyerSig.from)
        assert(buyerBalance.eq(ether(0)), `unxpected token balance: ${buyerBalance.div(1e18).toString(10)}`)
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
  })
})