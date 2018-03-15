import expectThrow from "zeppelin-solidity/test/helpers/expectThrow";

const DefaultToken = artifacts.require('./DefaultToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')
const AltExtraHolderContract = artifacts.require('./AltExtraHolderContract.sol')

function sig (from, value) {
  if (typeof from == 'undefined') {
    throw new Error('field from is required. Pass signature account as first argument')
  }
  if (typeof value == 'undefined') {
    value = 0
  }

  return { from, value }
}

contract("Extra Holder", ([owner]) => {
  let registry, token, holding

  const [
    bounty,
    network,
    community
  ] = [
    "0x84bE27E1d3AeD5e6CF40445891d3e2AB7d3d98e8",
    "0xffcf8fdee72ac11b5c542428b35eef5769c409f0",
    "0x22d491bde2303f2f43325b2108d26f1eaba1e32b"
  ]

  before(async () => {
    // setup dependencies
    registry = await UserRegistry.new()
    token = await DefaultToken.new('Test Token', 'TST', 18, registry.address)
    holding = await AltExtraHolderContract.new(token.address)
    registry.addSystem(holding.address)
    await token.mint(owner, 1000000e18)
  })

  describe('token receive', async () => {
    it('should increate total received amount', async () => {
      const beforeTotal = await holding.totalReceived();
      await token.transfer(holding.address, 100e19)
      const afterTotal = await holding.totalReceived();
      assert.equal(100, afterTotal.sub(beforeTotal).div(10e18).toNumber())
    })

    it('should withdraw proper amount', async () => {
      const beforeBalances = {}
      const afterBalances = {}
      
      beforeBalances.bounty = await token.balanceOf(bounty)
      beforeBalances.network = await token.balanceOf(network)
      beforeBalances.community = await token.balanceOf(community)
      await holding.withdraw(bounty)
      await holding.withdraw(network)
      await holding.withdraw(community)
      afterBalances.bounty = await token.balanceOf(bounty)
      afterBalances.network = await token.balanceOf(network)
      afterBalances.community = await token.balanceOf(community)

      assert.equal(5, afterBalances.bounty.sub(beforeBalances.bounty).div(10e18).toNumber())
      assert.equal(45, afterBalances.network.sub(beforeBalances.network).div(10e18).toNumber())
      assert.equal(50, afterBalances.community.sub(beforeBalances.community).div(10e18).toNumber())
    })
  })
})