var VaultContract = artifacts.require("Vault");
var HDWalletProvider = require("truffle-hdwallet-provider");


module.exports = function(deployer){
    var mnemonic = "avoid aunt cool tent speed skull pony radio deposit tornado country wrestle";
    // var managerAddress = HDWalletProvider(mnemonic, "http://localhost:8545", 0);
    var panicAddress = HDWalletProvider(mnemonic, "http://localhost:8545", 1);

    deployer.deploy(VaultContract, panicAddress, 900, 1);
}