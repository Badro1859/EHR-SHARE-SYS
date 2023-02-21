var authority = artifacts.require("./HealthAuthority.sol");
var healthActor = artifacts.require("./HealthActor.sol");

module.exports = function(deployer) {
  deployer.deploy(healthActor, authority.address);
};