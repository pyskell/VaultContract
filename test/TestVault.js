var Vault = artifacts.require("Vault");
// var HDWalletProvider = require("truffle-hdwallet-provider");

// Calling functions from a specific account/address: contract.function.call({from: accounts[0]})
// Creating transactions from a specific account/address: contract.function(args, {from: accounts[0]})
// So should be able to send money via: contract.(amount, {from: accounts[0]}) ... or something
contract('Vault', function(accounts){
    accounts[0].balance = 10000000000000000;
    it("should accept a deposit and credit it to the msg.sender"), function(){
        return Vault.deployed().then(function(instance){
            // var mnemonic = "avoid aunt cool tent speed skull pony radio deposit tornado country wrestle";
            // var managerAddress = HDWalletProvider(mnemonic, "http://localhost:8545", 0);
            var managerAddress = accounts[0];
            instance.send(1, {from: managerAddress});
            return instance.getBalance.call({from: managerAddress}).then(function(balance){
                return assert.equal(balance.valueOf(), 1, "1 wei wasn't credited");
                }
            );
        });
    }

    it("should assert true"), function(){
        return assert.equal(true, true, "true is true");
    }
});