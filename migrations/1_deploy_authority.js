const Web3 = require('web3');
const TruffleConfig = require('../truffle-config');

var authority = artifacts.require("./HealthAuthority.sol");

module.exports = async function(deployer, network, accounts) {
  // const config = TruffleConfig.networks[network];
  const fromAccount = accounts[0];
  console.log("selected account: ", fromAccount);
  deployer.deploy(authority);
};