const SQM1Token = artifacts.require("./SQM1Token.sol")
const SQM1Crowdsale = artifacts.require("./SQM1Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function(deployer) {
  let owner = web3.eth.accounts[0]
  await deployer.deploy(
    SQM1Crowdsale,
    UserRegistry.address,
    SQM1Token.address,
    owner,
    AltToken.address
  )
}