const AltCrowdsale = artifacts.require("./AltCrowdsale.sol");
const AltToken = artifacts.require("./AltToken.sol");
const UserRegistry = artifacts.require("./UserRegistry.sol");

module.exports = async deployer => {
  const registry = await UserRegistry.deployed()

  for (let acc of web3.eth.accounts) {
    await registry.addAddress(acc)
  }

  const token = await AltToken.deployed()
  token.transferOwnership(AltCrowdsale.address)
}
