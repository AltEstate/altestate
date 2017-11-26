import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const AltCrowdsalePhaseOne = artifacts.require("./AltCrowdsalePhaseOne.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

contract('ICO', accounts => {
  let crowdsale, token, registry

  async function balanceEqualTo (client, should) {
    let balance = await token.balanceOf(client, { from: client })
    let decimals = await token.decimals()
    let expected = new web3.BigNumber(should).mul(10 ** decimals)
    assert(balance.eq(expected), `Token balance should be equal to ${expected}, but got: ${balance.toString(10)} (${balance.toNumber() / (10 ** decimals)})`)
  }

  beforeEach(async () => {
    const now = latestTime()

    registry = await UserRegistry.new()
    token = await AltToken.new(registry.address)
    crowdsale = await AltCrowdsalePhaseOne.new(
      registry.address,
      token.address,
      [
        duration.days(3),
        duration.days(5),
        duration.days(10),
        duration.days(25)
      ],
      [
        2000, // 20%
        1500,
        1000,
        0
      ]
    )

    await token.transferOwnership(crowdsale.address)

    for (let index = 0; index < 3; index++) {
      await registry.addAddress(accounts[index])
    }
  })

  it('sane?', async () => {
    let sane = await crowdsale.isSane()
    assert(sane, 'not ready yet?')
  })

  it('owner?', async () => {
    assert((await token.owner()) === crowdsale.address)
  })

  it('known user?', async () => {
    assert(registry.knownAddress(accounts[0]))
  })

  it('try buy', async () => {
    let r = await crowdsale.buyTokens(accounts[0], { from: accounts[0], value: ether(1) })
    balanceEqualTo(accounts[0], 100)
  })

  it('try issue with bitcoin', async () => {
    const hash = '0x9b150c055e8169ef6deb1a110e3bf9765f398a3fcdcfa754b4cc00c2986ecd33'
    let r = await crowdsale.buyWithBitcoin(accounts[1], 100 * 1e10, hash, { from: accounts[0] })
    const logHash = r.logs.filter(l => l.event === 'BitcoinSale').map(l => l.args.bitcoinHash)
    assert(logHash.includes(hash), 'source hash not found!')
    balanceEqualTo(accounts[1], 100)
  })

  it('prevent to buy from unknown person', async () => {
    expectThrow(crowdsale.buyTokens(accounts[5], { from: accounts[5], value: ether(1) }))
  })

  it('prevent to mint more than hard cap', async () => {
    await crowdsale.buyTokens(accounts[1], { from: accounts[1], value: ether(1) })
    expectThrow(crowdsale.buyTokens(accounts[2], { from: accounts[2], value: ether(0.1) }))
  })

  it('should be half of cap', async () => {
    await crowdsale.buyTokens(accounts[1], { from: accounts[1], value: ether(0.5) })

    const total = await token.totalSupply()
    const cap = await token.cap()

    assert(total.div(cap).eq(0.5), `non half of cap!`)
  })
})