const SQM1Token = artifacts.require("./SQM1Token.sol")
const SQM1Crowdsale = artifacts.require("./SQM1Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function(deployer) {
  let owner = web3.eth.accounts[0]

  await UserRegistry.at(UserRegistry.address).addSystem(SQM1Crowdsale.address)
  await SQM1Token.at(SQM1Token.address).transfer(SQM1Crowdsale.address, web3.toWei(10000, 'ether'), { from: owner })
  await SQM1Crowdsale.at(SQM1Crowdsale.address).saneIt()
}