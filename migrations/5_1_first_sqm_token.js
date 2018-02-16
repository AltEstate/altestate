const SQM1Token = artifacts.require("./SQM1Token.sol")
const SQM1Crowdsale = artifacts.require("./SQM1Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function(deployer) {
  await deployer.deploy(SQM1Token, UserRegistry.address)
}