const AltCrowdsalePhaseOne = artifacts.require('./AltCrowdsalePhaseOne.sol')
// const AltCrowdsalePhaseTwo = artifacts.require('./AltCrowdsalePhaseTwo.sol')
const Crowdsale = artifacts.require('./Crowdsale.sol')
const AltToken = artifacts.require('./AltToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')
const AltExtraHolderContract = artifacts.require('./AltExtraHolderContract.sol')

module.exports = async function (deployer) {
  let owner = '0x07eBF23D47C16c9bfc5510C0E931e397a60F7F11'
  deployer.deploy(AltCrowdsalePhaseOne,
    UserRegistry.address,
    AltToken.address,
    AltExtraHolderContract.address,
    owner
  )
}
