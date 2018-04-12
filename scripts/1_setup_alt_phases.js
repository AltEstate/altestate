const AltCrowdsalePhaseOne = artifacts.require('./demoAltCrowdsalePhaseOne.sol')
// const AltCrowdsalePhaseTwo = artifacts.require('./AltCrowdsalePhaseTwo.sol')
const Crowdsale = artifacts.require('./Crowdsale.sol')
const AltToken = artifacts.require('./AltToken.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

function ether (n) {
  return new web3.BigNumber(web3.toWei(n, 'ether'))
}

const duration = {
  seconds: function (val) { return val },
  minutes: function (val) { return val * this.seconds(60) },
  hours: function (val) { return val * this.minutes(60) },
  days: function (val) { return val * this.hours(24) },
  weeks: function (val) { return val * this.days(7) },
  years: function (val) { return val * this.days(365) },
}

module.exports = async function (callback) {
  try {
    const token = AltToken.at(AltToken.address)
    const crowdsale = AltCrowdsalePhaseOne.at(AltCrowdsalePhaseOne.address)
    console.log(`Token owner is ${await token.owner()}`)
    console.log('transfer ownership of ALT token to crowdsale contract (Phase One)')
    await token.transferOwnership(crowdsale.address)

    console.log('Setup tier 1 bonus')
    await crowdsale.setTimeBonuses(
        [ duration.days(60) ],
        [                 0 ]
    );

    await crowdsale.saneIt()

    callback(null)
  } catch (error) {
    callback(error)
  }
}