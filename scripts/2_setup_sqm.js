const SQM1Token = artifacts.require('./SQM1Token.sol')
const SQM1Crowdsale = artifacts.require('./SQM1Crowdsale.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

module.exports = async function (callback) {
  try {
    let owner = web3.eth.accounts[0]
    const registry = UserRegistry.at(UserRegistry.address)
    const token = SQM1Token.at(SQM1Token.address)
    const sale = SQM1Crowdsale.at(SQM1Crowdsale.address)

    console.log('Add SQM crowdsale address to registry as system')
    await registry.addSystem(sale.address)
    console.log('Transfer SQM tokens to sale address')
    await token.transfer(sale.address, web3.toWei(10000, 'ether'))
    console.log('Sanetize sale contract')
    await sale.saneIt()

    callback(null)
  } catch (error) {
    callback(error)
  }
}