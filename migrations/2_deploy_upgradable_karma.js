const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const Karma = artifacts.require("Karma");

module.exports = async function (deployer) {
  const instance = await deployProxy(Karma, { deployer });
  console.log("Deployed", instance.address);
};
