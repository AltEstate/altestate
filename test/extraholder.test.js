import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import expectThrow from "zeppelin-solidity/test/helpers/expectThrow"
import { duration } from 'zeppelin-solidity/test/helpers/increaseTime'
import ether from 'zeppelin-solidity/test/helpers/ether'

const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')
const ExtraHolderContract = artifacts.require('./ExtraHolderContract.sol')
const Crowdsale = artifacts.require('./Crowdsale.sol')

function tokens(n) {
  return ether(n)
}

function sig (from, value) {
  if (typeof from == 'undefined') {
    throw new Error('field from is required. Pass signature account as first argument')
  }
  if (typeof value == 'undefined') {
    value = 0
  }

  return { from, value }
}

function setFlags (crowdsale, flags, sig) {
  const flagsMap = {
    whitelisted: 0,
    knownOnly: 1,
    amountBonus: 2,
    earlyBonus: 3,
    tokenExcange: 4,
    allowToIssue: 5,
    disableEther: 6,
    extraDistribution: 7,
    transferShipment: 8,
    cappedInEther: 9,
    personalBonuses: 10,
    allowClaimBeforeFinalization: 11
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

contract("Extra Holder", ([owner, alice, bob, carol, dave, strange]) => {
  let registry, token, holding

  before(async () => {
    // setup dependencies
    registry = await UserRegistry.new()
    token = await DefaultToken.new('Test Token', 'TST', 18, registry.address)
    await token.mint(owner, 1000000e18)
  })

  it('should reject creation without correct number of recipients shares', async () => {
    // Incorrect amount of shares
    // Providen 3 repicients addresses and only one share amount
    await expectThrow(ExtraHolderContract.new(token.address, [ alice, bob, carol], [ 100e2 ]))
  })

  it('should reject creation with non 10000 sum of shares', async () => {
    // Only 30% of total shares
    await expectThrow(ExtraHolderContract.new(token.address, [ alice, bob, carol], [ 10e2, 10e2, 10e2 ]))
  })
  
  it('should reject creation witout recipients', async () => {
    await expectThrow(ExtraHolderContract.new(token.address, [], []))
  })

  it('should create holder contract', async () => {
    holding = await ExtraHolderContract.new(token.address,
      [ alice, bob, carol ],
      [ 60e2, 35e2, 5e2 ]
    )
    
    registry.addSystem(holding.address)
  })

  describe('token receive', async () => {
    it('should increate total received amount', async () => {
      const beforeTotal = await holding.totalReceived()
      await token.transfer(holding.address, 10e19)

      const afterTotal = await holding.totalReceived()
      assert.equal(10, afterTotal.sub(beforeTotal).div(10e18).toNumber())
    })

    it('should allow to withdraw funds', async () => {
      const beforeBalance = await token.balanceOf(alice)
      await holding.withdraw(alice, sig(alice))
      const afterBalance = await token.balanceOf(alice)
      assert.equal(6, afterBalance.sub(beforeBalance).div(10e18).toNumber())
    })

    it('should withdraw only first time', async () => {
      const beforeBalance = await token.balanceOf(alice)
      await expectThrow(holding.withdraw(alice, sig(alice)))
    })

    it('should withdraw proper value after another transfer', async () => {
      // more 10 tokens
      await token.transfer(holding.address, 10e19)
      
      const beforeBalance = await token.balanceOf(carol)
      await holding.withdraw(carol, sig(carol))
      const afterBalance = await token.balanceOf(carol)
      assert.equal(1, afterBalance.sub(beforeBalance).div(10e18).toNumber())
    })

    it('should allow to take again after new transfer', async () => {      
      const beforeBalance = await token.balanceOf(alice)
      await holding.withdraw(alice, sig(alice))
      const afterBalance = await token.balanceOf(alice)
      assert.equal(6, afterBalance.sub(beforeBalance).div(10e18).toNumber())
    })

    it('should withdraw all available part', async () => {      
      const beforeBalance = await token.balanceOf(bob)
      await holding.withdraw(bob, sig(bob))
      const afterBalance = await token.balanceOf(bob)
      assert.equal(7, afterBalance.sub(beforeBalance).div(10e18).toNumber())
    })
  })

  describe('crowdsale integration', () => {
    let crowdsale
    before(async () => {
      registry = await UserRegistry.new()
      token = await DefaultToken.new('Test Token', 'TST', 18, registry.address)
      holding = await ExtraHolderContract.new(
        token.address,
        [ alice, bob, carol ],
        [ 60e2, 35e2, 5e2 ]
      )
      
      registry.addSystem(holding.address)
      crowdsale = await Crowdsale.new(sig(owner))

      await registry.addSystem(crowdsale.address, sig(owner))
      await crowdsale.setToken(token.address, sig(owner))

      const time = latestTime()
      await crowdsale.setTime(time - duration.days(1), time + duration.days(30), sig(owner))
      await crowdsale.setPrice(ether(1).div(100), sig(owner)) // 1 eth -> 100 tokens
      await crowdsale.setWallet(owner, sig(owner))
      await crowdsale.setSoftHardCaps(
        tokens(1e5), // soft cap is 100k
        tokens(1e6)  // hard cap is 1kk
      )  
      await token.transferOwnership(crowdsale.address, sig(owner))
      await setFlags(crowdsale, { extraDistribution: true}, sig(owner))
      await crowdsale.setExtraDistribution(holding.address, 3000) // 30%
      await crowdsale.saneIt()
    })
    
    it('should mint extra tokens', async () => {
      const balanceBefore = await token.balanceOf(holding.address)
      await crowdsale.buyTokens(strange, { value: ether(1), from: strange })
      const balanceAfter  = await token.balanceOf(holding.address)
      assert.equal(30, balanceAfter.sub(balanceBefore).div(1e18).toNumber(), `unxpected extra distribution amount: ${balanceAfter.sub(balanceBefore).div(1e18).toString(10)}`)
    })

    it('should increate total received', async () => {
      const total = await holding.totalReceived()
      assert.equal(30, total.div(1e18).toNumber())
    })

    it('should split extra', async () => {
      const beforeBalance = await token.balanceOf(alice)
      await holding.withdraw(alice, sig(alice))
      const afterBalance = await token.balanceOf(alice)
      assert.equal(18, afterBalance.sub(beforeBalance).div(1e18).toNumber())
    })
  })
})