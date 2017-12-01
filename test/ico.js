import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const AltCrowdsalePhaseOne = artifacts.require("./AltCrowdsalePhaseOne.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

function bn (from) {
  return new web3.BigNumber(from)
}

contract('ICO', accounts => {
  let ownerSig = { from: accounts[0] }
  let crowdsale, token, registry

  async function balanceEqualTo (client, should) {
    let balance = await token.balanceOf(client, { from: client })
    let decimals = await token.decimals()
    let expected = new web3.BigNumber(should).mul(10 ** decimals)
    assert(balance.eq(expected), `Token balance should be equal to ${expected}, but got: ${balance.toString(10)} (${balance.toNumber() / (10 ** decimals)})`)
  }

  beforeEach(async () => {
    const now = latestTime()

    registry = await UserRegistry.new(ownerSig)
    token = await AltToken.new(registry.address, ownerSig)
    crowdsale = await AltCrowdsalePhaseOne.new(
      registry.address,
      token.address,
      accounts[4],
      3000,
      [
        duration.days(5),
        duration.days(10),
        duration.days(15),
        duration.days(20)
      ],
      [
        2000, // 20%
        1500,
        1000,
        0
      ],
      ownerSig
    )

    const debugEvent = crowdsale.Debug({}, { fromBlock: 0, toBlock: 'latest'})
    debugEvent.watch((error, result) => {
      if (error) {
        return console.error(error)
      }

      return console.log(result.args.message)
    })

    await token.transferOwnership(crowdsale.address)

    for (let index = 0; index < 3; index++) {
      await registry.addAddress(accounts[index])
    }

    await crowdsale.saneIt()
  })

  it('sane?', async () => {
    let sane = await crowdsale.state()
    assert(sane.eq(1), `not ready yet? state is ${sane}`)
  })

  it('owner?', async () => {
    assert((await token.owner()) === crowdsale.address)
  })

  it('known user?', async () => {
    assert(registry.knownAddress(accounts[0]))
  })

  it('time slices', async () => {
    const timeSlice0 = await crowdsale.timeSlices(0)
    const timeSlice1 = await crowdsale.timeSlices(1)
    const timeSlice2 = await crowdsale.timeSlices(2)
    const timeSlice3 = await crowdsale.timeSlices(3)

    assert(timeSlice0.eq(60 * 60 * 24 *  5), `unxpected time slise 0: ${timeSlice0.toString(10)}`)
    assert(timeSlice1.eq(60 * 60 * 24 * 10), `unxpected time slise 1: ${timeSlice1.toString(10)}`)
    assert(timeSlice2.eq(60 * 60 * 24 * 15), `unxpected time slise 2: ${timeSlice2.toString(10)}`)
    assert(timeSlice3.eq(60 * 60 * 24 * 20), `unxpected time slise 3: ${timeSlice3.toString(10)}`)
  })
  
  it('time bonuses', async () => {
    const timeBonuses0 = await crowdsale.timeBonuses(60 * 60 * 24 *  5)
    const timeBonuses1 = await crowdsale.timeBonuses(60 * 60 * 24 * 10)
    const timeBonuses2 = await crowdsale.timeBonuses(60 * 60 * 24 * 15)
    const timeBonuses3 = await crowdsale.timeBonuses(60 * 60 * 24 * 20)

    assert(timeBonuses0.eq(2000), `unxpected time bonus 0: ${timeBonuses0.toString(10)}`)
    assert(timeBonuses1.eq(1500), `unxpected time bonus 1: ${timeBonuses1.toString(10)}`)
    assert(timeBonuses2.eq(1000), `unxpected time bonus 2: ${timeBonuses2.toString(10)}`)
    assert(timeBonuses3.eq(   0), `unxpected time bonus 3: ${timeBonuses3.toString(10)}`)
  })

  describe('allow any try to buy', () => {
    beforeEach(async () => {
      await crowdsale.addToWhitelist(accounts[1], 1, bn(1e25)) // much enough :0
    })

    it('try buy', async () => {
      let r = await crowdsale.buyTokens(accounts[1], { from: accounts[1], value: ether(1) })
      balanceEqualTo(accounts[1], 120) // 100 + 20% bonus!
    })
    
    it('try issue with bitcoin', async () => {
      const hash = '0x9b150c055e8169ef6deb1a110e3bf9765f398a3fcdcfa754b4cc00c2986ecd33'
      let r = await crowdsale.buyWithHash(accounts[1], ether(1), latestTime(), hash, { from: accounts[0] })
      const logHash = r.logs.filter(l => l.event === 'HashSale').map(l => l.args.bitcoinHash)
      assert(logHash.includes(hash), 'source hash not found!')
      balanceEqualTo(accounts[1], 120) // 100 + 20% bonus!
    })
  
    it('prevent to buy from unknown person', async () => {
      expectThrow(crowdsale.buyTokens(accounts[5], { from: accounts[5], value: ether(1) }))
    })
  
    it('prevent to mint more than hard cap', async () => {
      await crowdsale.buyTokens(accounts[1], { from: accounts[1], value: ether(10) })
      expectThrow(crowdsale.buyTokens(accounts[2], { from: accounts[2], value: ether(0.1) }))
    })
  
    it('should be half of cap', async () => {
      await crowdsale.buyTokens(accounts[1], { from: accounts[1], value: ether(5) })
  
      const total = await crowdsale.weiRaised()
      const cap = await crowdsale.hardCap()
  
      assert(total.div(cap).eq(0.5), `non half of cap!`)
    })
  })
})