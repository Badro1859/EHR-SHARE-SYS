var authority = artifacts.require("./HealthAuthority.sol");
var healthActor = artifacts.require("./HealthActor.sol");
var patient = artifacts.require("./Patient.sol")



module.exports = function(deployer) {
  deployer.deploy(patient, authority.address, healthActor.address);
};