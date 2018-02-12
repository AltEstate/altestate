import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

let owner, manager, buyer, buyerWithIdentity, stranger, random, random2, system
let sig = {}
let registry, token

async function createContext () { 
  registry = await UserRegistry.new(sig.owner)
  await registry.grant(manager, sig.owner)
  await registry.addAddress(buyer, sig.owner)
  await registry.addIdentity(buyerWithIdentity, sig.owner)
  await registry.addSystem(owner, sig.owner)
  await registry.addSystem(manager, sig.owner)
  await registry.addSystem(system, sig.owner)
  token = await DefaultToken.new("Test Token", "TST", 18, registry.address, sig.owner)
  await token.mint(owner, ether(1e6), sig.owner)
}

async function clearContext () {}

function makeSig (address) {
  return { from: address }
}

contract("Custom token", accounts => {
  [ owner, manager, buyer, buyerWithIdentity, stranger, random, random2, system ] = accounts

  sig = {
    owner: makeSig(owner),
    manager: makeSig(manager), 
    buyer: makeSig(buyer),
    buyerWithIdentity: makeSig(buyerWithIdentity),
    stranger: makeSig(stranger), 
    system: makeSig(system),
  }

  describe('primary', async () => {
    before(createContext)
    after(clearContext)

    it ('should be frozen by default', async () => {
      assert.isFalse(await token.unfrozen())
    })

    it ('should allow to transfer between system accounts', async () => {
      await token.transfer(system, ether(10), sig.owner)
    })

    it ('shouw allow to transfer from system to non-system account', async () => {
      await token.transfer(buyer, ether(10), sig.owner)
      await token.transfer(buyerWithIdentity, ether(10), sig.owner)

      assert.isTrue((await token.balanceOf(buyer)).div(1e18).eq(10))
      assert.isTrue((await token.balanceOf(buyerWithIdentity)).div(1e18).eq(10))
    })
    
    it ('shouw allow to transfer from system to unkown account', async () => {
      await token.transfer(stranger, ether(10), sig.owner)
      assert.isTrue((await token.balanceOf(stranger)).div(1e18).eq(10))
    })

    it ('shouldnt allow non-owner account to take away tokens', async () => {
      await expectThrow(token.takeAway(buyer, manager, sig.manager))
    })

    it ('should allow to take away tokens from account without identity', async () => {
      assert.isTrue((await token.balanceOf(buyer)).div(1e18).eq(10))
      await token.takeAway(buyer, owner, sig.owner)
      assert.isTrue((await token.balanceOf(buyer)).div(1e18).eq(0))

      await token.transfer(buyer, ether(10), sig.owner)
    })

    it ('should reject transaction while token is frozen', async () => {
      await expectThrow(token.transfer(random, ether(1), sig.buyer))
      await expectThrow(token.transfer(random, ether(1), sig.buyerWithIdentity))
      await expectThrow(token.transfer(random, ether(1), sig.stranger))
    })

    it ('should allow to transfer token to system address', async () => {
      await token.transfer(system, ether(1), sig.buyer)
      await token.transfer(system, ether(1), sig.buyerWithIdentity)
      await token.transfer(system, ether(1), sig.stranger)
    })

    it ('should reject trying to unfrezee token without rights', async () => {
      await expectThrow(token.unfrezee(sig.buyer))
    })

    it ('should allow owner to unfrezee token', async () => {
      await token.unfrezee(sig.owner)
      assert.isTrue(await token.unfrozen())
    })

    it ('should reject transfer without identity', async () => {
      await expectThrow(token.transfer(random, ether(1), sig.buyer))
    })

    it ('should allow transfer with identity', async () => {
      await token.transfer(random, ether(1), sig.buyerWithIdentity)
    })

    it ('should allow to transfer tokens from unkown addresses', async () => {
      await token.transfer(random, ether(1), sig.stranger)
      await token.transfer(random2, ether(1), { from: random })
    })

    it ('should allow to transfer after add identity', async () => {
      await registry.addIdentity(buyer, sig.owner)
      await token.transfer(random, ether(1), sig.buyer)

    })
  })
})