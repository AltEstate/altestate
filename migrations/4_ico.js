const Crowdsale = artifacts.require("./Crowdsale.sol");
const AltToken = artifacts.require("./AltToken.sol");
const UserRegistry = artifacts.require("./UserRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(Crowdsale,
    1512086400, //12/01/2017 @ 12:00am (UTC),
    1512086400 + 60 * 60 * 24 * 30, // 30 days  
    1e16, // 1 eth -> 100 alt
    AltToken.address,
    web3.eth.coinbase,
    UserRegistry.address);
};
