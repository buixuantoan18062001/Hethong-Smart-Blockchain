var SupplyChainCafe = artifacts.require("./SupplyChainCafe.sol");

module.exports = function(deployer) {
    deployer.deploy(SupplyChainCafe);
};
