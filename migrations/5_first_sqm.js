const SQM1Token = artifacts.require("./SQM1Token.sol")
const SQM1Crowdsale = artifacts.require("./SQM1Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function(deployer) {
  console.log(web3.B)
  let owner = web3.eth.accounts[0]
  await deployer.deploy(SQM1Token, UserRegistry.address)
  await deployer.deploy(
    SQM1Crowdsale,
    UserRegistry.address,
    SQM1Token.address,
    owner,
    AltToken.address
  )

  await SQM1Token.at(SQM1Token.address).transfer(SQM1Crowdsale.address, web3.toWei(10000, 'ether'), { from: owner })
  await SQM1Crowdsale.at(SQM1Crowdsale.address).saneIt()
};
