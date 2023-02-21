var authority = artifacts.require("./HealthAuthority.sol");
var healthActor = artifacts.require("./HealthActor.sol");
var patient = artifacts.require("./Patient.sol")


module.exports = async function(deployer) {
  deployer.deploy(authority);
};