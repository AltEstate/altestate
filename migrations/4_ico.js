const AltCrowdsalePhaseOne = artifacts.require("./AltCrowdsalePhaseOne.sol")
const AltCrowdsalePhaseTwo = artifacts.require("./AltCrowdsalePhaseTwo.sol")
const Crowdsale = artifacts.require("./Crowdsale.sol")
const AltToken = artifacts.require("./AltToken.sol")
const UserRegistry = artifacts.require("./UserRegistry.sol")

module.exports = async function (deployer) {
  let owner = web3.eth.accounts[0]

  const phaseOne = await deployer.deploy(AltCrowdsalePhaseOne,
    UserRegistry.address,
    AltToken.address,
    owner,
    owner
  )

  const phaseTwo = await deployer.deploy(AltCrowdsalePhaseTwo,
    UserRegistry.address,
    AltToken.address,
    owner,
    owner
  )

  console.log(AltCrowdsalePhaseOne.address)
  console.log(AltCrowdsalePhaseTwo.address)

  await AltToken.at(AltToken.address).transferOwnership(AltCrowdsalePhaseOne.address)
  console.log(await AltToken.at(AltToken.address).owner())
  await Crowdsale.at(AltCrowdsalePhaseOne.address).saneIt()
}
