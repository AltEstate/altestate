const SQM1Token = artifacts.require('./SQM1Token.sol')
const SQM2Token = artifacts.require('./SQM2Token.sol')
const SQM3Token = artifacts.require('./SQM3Token.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

module.exports = function (deployer) {
  deployer.deploy(SQM1Token, UserRegistry.address)
  deployer.deploy(SQM2Token, UserRegistry.address)
  deployer.deploy(SQM3Token, UserRegistry.address)
}
