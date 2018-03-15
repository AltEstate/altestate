const SQM1Token = artifacts.require("./SQM1Token.sol")
const SQM2Token = artifacts.require("./SQM2Token.sol")
const SQM3Token = artifacts.require("./SQM3Token.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function(deployer) {
  await deployer.deploy(SQM1Token, UserRegistry.address)
  await deployer.deploy(SQM2Token, UserRegistry.address)
  await deployer.deploy(SQM3Token, UserRegistry.address)
}