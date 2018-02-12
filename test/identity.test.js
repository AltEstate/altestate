import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import increaseTime, { duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import ether from 'zeppelin-solidity/test/helpers/ether';
import moment from 'moment';

const UserRegistry = artifacts.require('./UserRegistry.sol')

let registry, ownerSig, managerSig, buyerSig, owner, manager, buyer, stranger, system


contract('UserRegistry', accounts => {
  [ owner, manager, buyer, stranger, system ] = accounts
  ownerSig = { from: owner }
  managerSig = { from: manager }
  buyerSig = { from: buyer }

  describe('registry creation', async () => {
    it('should create instance of registry', async () => {
      registry = await UserRegistry.new(ownerSig)
    })

    it('should grant rights to owner', async () => {
      assert.isTrue(await registry.isOwner(ownerSig))
      assert.isTrue((await registry.publisher()) === owner)
      assert.isFalse(await registry.isOwner(managerSig))
      assert.isFalse(await registry.isOwner(buyerSig))
    })

    it('should reject actions wo rights', async () => {
      await expectThrow(registry.addAddress(buyer, managerSig))
      await expectThrow(registry.addIdentity(buyer, buyerSig))
      await expectThrow(registry.addSystem(buyer, managerSig))
    })

    it('should allow owner to grant rights', async () => {
      await registry.grant(manager, ownerSig)
      assert.isTrue(await registry.isOwner(managerSig))
      assert.isTrue(await registry.checkOwner(manager))
    })

    it('should left owner rights after granting', async () => {
      assert.isTrue(await registry.isOwner(ownerSig))
      assert.isTrue(await registry.isOwner(managerSig))
    })

    it('should allow to add address after receiving rights', async () => {
      assert.isFalse(await registry.knownAddress(buyer))
      await registry.addAddress(buyer, managerSig)
      assert.isTrue(await registry.knownAddress(buyer))
    })

    it('should allow to add identities to address', async () => {
      assert.isFalse(await registry.hasIdentity(buyer))
      await registry.addIdentity(buyer, ownerSig)
      assert.isTrue(await registry.hasIdentity(buyer))
    })

    it('should set address as known after add identity', async () => {
      assert.isFalse(await registry.knownAddress(stranger))
      await registry.addIdentity(stranger, managerSig)
      assert.isTrue(await registry.knownAddress(stranger))
    })

    it('should allow to setup system address', async () => {
      assert.isFalse(await registry.knownAddress(system))
      assert.isFalse(await registry.hasIdentity(system))
      assert.isFalse(await registry.systemAddress(system))

      await registry.addSystem(system, ownerSig)

      assert.isFalse(await registry.hasIdentity(system))
      assert.isFalse(await registry.knownAddress(system))
      assert.isTrue(await registry.systemAddress(system))
    })

    it('should reject extra owners to revoke publisher rights', async () => {
      await expectThrow(registry.revoke(owner, managerSig))
      assert.isTrue(await registry.isOwner(ownerSig))
    })

    it('should allow to revoke rights', async () => {
      await registry.revoke(manager, ownerSig)
      assert.isFalse(await registry.isOwner(managerSig))
      assert.isFalse(await registry.checkOwner(manager))
    })
  })
})