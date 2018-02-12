var AltToken = artifacts.require("./AltToken.sol");
var UserRegistry = artifacts.require("./UserRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(AltToken, UserRegistry.address);
};
