const AltCrowdsalePhaseOne = artifacts.require('./AltCrowdsalePhaseOne.sol')
const AltCrowdsalePhaseTwo = artifacts.require('./AltCrowdsalePhaseTwo.sol')
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
 
    console.log('Setup amount bonuses')
    await crowdsale.setAmountBonuses(
      [ ether(3), ether(10) ],
      [      500,      1000 ]
    )

    console.log('Setup tier 1 bonus')
    let now_utc = await phaseOne.startTime();
    let timeBonusDuration = Math.round(Date.UTC(2018, 3, 20, 11)/1000) -  now_utc
    await phaseOne.setTimeBonuses(
        [ timeBonusDuration ],
        [              2500 ]
    );

    await crowdsale.saneIt()

    callback(null)
  } catch (error) {
    callback(error)
  }
}