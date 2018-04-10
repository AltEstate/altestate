const AltToken = artifacts.require('./AltToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

module.exports = function(deployer) {
  deployer.deploy(AltToken, UserRegistry.address)
}
