const { upgradeProxy } = require("@openzeppelin/truffle-upgrades");

const Karma = artifacts.require("Karma");
const KarmaV2 = artifacts.require("KarmaV2");

module.exports = async function (deployer) {
  const existing = await Karma.deployed();
  const instance = await upgradeProxy(existing.address, KarmaV2, { deployer });
  console.log("Upgraded", instance.address);
};
