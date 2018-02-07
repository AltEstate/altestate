import ether from 'zeppelin-solidity/test/helpers/ether';

const AltToken = artifacts.require('./AltToken.sol')
const SQM1Token = artifacts.require('./SQM1Token.sol')
const SQM1Crowdsale = artifacts.require('./SQM1Crowdsale.sol')
const UserRegistry = artifacts.require('./UserRegistry.sol')

function setFlags (crowdsale, flags, sig) {
  const flagsMap = {
    whitelisted: 0,
    knownOnly: 1,
    amountBonus: 2,
    earlyBonus: 3,
    refundable: 4,
    tokenExcange: 5,
    allowToIssue: 6,
    disableEther: 7,
    extraDistribution: 8,
    transferShipment: 9,
    cappedInEther: 10,
    personalBonuses: 11,
    allowClaimBeforeFinalization: 12
  }

  let flagArgs = Array(Object.keys(flagsMap).length).fill().map(e => false)
  for (let key in flags) {
    if (typeof flagsMap[key] === 'undefined') {
      throw new Error(`undefined arg key: ${key}`)
    }

    flagArgs[flagsMap[key]] = true
  }

  sig = sig || {}

  return crowdsale.setFlags(...flagArgs, sig)
}

function numberToBytearray(long, size) {
  // we want to represent the input as a 8-bytes array
  const byteArray = Array(size).fill(0);

  for (let index = byteArray.length - 1; index >= 0; index-- ) {
      let byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) / 256 ;
  }

  return byteArray;
}

function toHex(bytes) {
  let out = '0x'
  for (let index = 0; index < bytes.length; index++) {
    let byte = bytes[index]
    out += ('00' + (byte & 0xFF).toString(16)).slice(-2)
  }
  
  return out
}

function toBytes(bn) {
  bn = bn.toNumber ? bn.toNumber() : bn
  return toHex(numberToBytearray(bn, 32))
}

function hexToBytes(hexString) {
  let out = []
  for(let index = 2; index < hexString.length; index += 2) {
    out.push(`0x${hexString[index]}${hexString[index+1]}`)
  }

  return out
}

contract('SQM1 crowdsale', ([owner, buyer, someOne]) => {
  let crowdsale, sqm, alt

  it('setup tests', async () => {
    alt = await AltToken.new(UserRegistry.address)
    alt.mint(owner, ether(1e6))
    alt.mint(buyer, ether(1e6))

    sqm = await SQM1Token.new(
      UserRegistry.address
    )
    
    crowdsale = await SQM1Crowdsale.new(
      UserRegistry.address,
      sqm.address,
      owner,
      alt.address
    )

    let balance
    balance = await sqm.balanceOf(crowdsale.address)
    console.log(balance.div(1e18).toString(10))
    await UserRegistry.at(UserRegistry.address).addSystem(crowdsale.address, { from: owner })
    await sqm.transfer(crowdsale.address, ether(10000), { from: owner })
    await UserRegistry.at(UserRegistry.address).addAddress(buyer, { from: owner })
    balance = await sqm.balanceOf(crowdsale.address)
    console.log(balance.div(1e18).toString(10))
    await crowdsale.saneIt()
  })

  it('should allow to buy', async () => {
    const rate = await crowdsale.tokensValues(alt.address)
    const bytes = toBytes(rate)
    console.log(bytes, rate.toString(10))
    console.log((await alt.balanceOf(buyer)).toString(10))
    await alt.approveAndCall(crowdsale.address, ether(10), bytes, { from: buyer })

    const balance = await sqm.balanceOf(buyer)
    console.log(balance.div(1e18).toString(10))
  })

  // it('should increase balance', async () => {
  //   const balance = await sqm.balanceOf(buyer)
  //   console.log(balance.div(1e18).toString(10))
  //   assert(balance.eq(0))
  // })
})