const SQM1Token = artifacts.require('./SQM1Token.sol')
const SQM2Token = artifacts.require('./SQM2Token.sol')
const SQM3Token = artifacts.require('./SQM3Token.sol')
const SQM1Crowdsale = artifacts.require('./SQM1Crowdsale.sol')
const SQM2Crowdsale = artifacts.require('./SQM2Crowdsale.sol')
const SQM3Crowdsale = artifacts.require('./SQM3Crowdsale.sol')
const AltToken = artifacts.require('./AltToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

module.exports = function (deployer) {
  let owner = web3.eth.accounts[0]
  deployer.deploy(
    SQM1Crowdsale,
    UserRegistry.address,
    SQM1Token.address,
    owner,
    AltToken.address
  )
  deployer.deploy(
    SQM2Crowdsale,
    UserRegistry.address,
    SQM2Token.address,
    owner,
    AltToken.address
  )
  deployer.deploy(
    SQM3Crowdsale,
    UserRegistry.address,
    SQM3Token.address,
    owner,
    AltToken.address
  )
}
