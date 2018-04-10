const AltToken = artifacts.require('./AltToken.sol')
const AltExtraHolderContract = artifacts.require('./AltExtraHolderContract.sol')

module.exports = function(deployer) {
  deployer.deploy(AltExtraHolderContract, AltToken.address)
}
