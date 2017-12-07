const AltCrowdsalePhaseOne = artifacts.require("./AltCrowdsalePhaseOne.sol");
const AltCrowdsalePhaseTwo = artifacts.require("./AltCrowdsalePhaseTwo.sol");
const AltToken = artifacts.require("./AltToken.sol");
const UserRegistry = artifacts.require("./UserRegistry.sol");

module.exports = function(deployer) {
  let owner = web3.eth.accounts[0]

  deployer.deploy(AltCrowdsalePhaseOne,
    UserRegistry.address,
    AltToken.address,
    owner,
    owner
  );

  deployer.deploy(AltCrowdsalePhaseTwo,
    UserRegistry.address,
    AltToken.address,
    owner,
    owner
  );
};
