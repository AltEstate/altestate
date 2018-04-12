const AltCrowdsalePhaseOne = artifacts.require('./demoAltCrowdsalePhaseOne.sol')
// const AltCrowdsalePhaseTwo = artifacts.require('./AltCrowdsalePhaseTwo.sol')
const Crowdsale = artifacts.require('./Crowdsale.sol')
const AltToken = artifacts.require('./AltToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')
const AltExtraHolderContract = artifacts.require('./AltExtraHolderContract.sol')

module.exports = async function (deployer) {
  let owner = web3.eth.accounts[0]
  deployer.deploy(AltCrowdsalePhaseOne,
    UserRegistry.address,
    AltToken.address,
    AltExtraHolderContract.address,
    owner
  )
}
