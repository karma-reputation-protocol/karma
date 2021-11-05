let KarmaStore = artifacts.require("KarmaStore");

module.exports = function (deployer) {
  deployer.deploy(KarmaStore);
};
