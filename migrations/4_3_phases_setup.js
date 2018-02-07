const AltCrowdsalePhaseOne = artifacts.require("./AltCrowdsalePhaseOne.sol")
const AltCrowdsalePhaseTwo = artifacts.require("./AltCrowdsalePhaseTwo.sol")
const Crowdsale = artifacts.require("./Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function (deployer) {
  await AltToken.at(AltToken.address).transferOwnership(AltCrowdsalePhaseOne.address)
  await Crowdsale.at(AltCrowdsalePhaseOne.address).saneIt()
}

