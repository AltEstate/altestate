import expectThrow from "zeppelin-solidity/test/helpers/expectThrow";

const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')
const ExtraHolderContract = artifacts.require('./ExtraHolderContract.sol')

function sig (from, value) {
  if (typeof from == 'undefined') {
    throw new Error('field from is required. Pass signature account as first argument')
  }
  if (typeof value == 'undefined') {
    value = 0
  }

  return { from, value }
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
      const beforeTotal = await holding.totalReceived();
      await token.transfer(holding.address, 10e19)

      const afterTotal = await holding.totalReceived();
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
})