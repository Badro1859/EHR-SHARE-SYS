var authority = artifacts.require("./HealthAuthority.sol");
var healthActor = artifacts.require("./HealthActor.sol");
var patient = artifacts.require("./Patient.sol")

/*
when deployed smart contract :
  1 - deploy authority contract only (comment authers contract)
  2 - deploy healthActor only (comment authers contract) with address of authority in argument
  3 - deploy patient only (comment authers contract) with address of authority and healthActor in argument
*/

module.exports = function(deployer) {
  // deployer.deploy(authority);
  // deployer.deploy(healthActor, "0xAc5813e2E23eA0fe1F21730B2b4AfAE8d01E87f3");
  deployer.deploy(patient, "0xAc5813e2E23eA0fe1F21730B2b4AfAE8d01E87f3", "0x650285fAB1EF6518fD77C73433b42d298303aB9A");
};