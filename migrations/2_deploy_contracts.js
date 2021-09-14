var SimpleStorage = artifacts.require("./FoodSupply.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
};
