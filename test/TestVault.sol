import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Vault.sol";

contract TestVault {
  public uint initialBalance = 10 ether;

  function testDeposit() {
    Vault vault = Vault(DeployedAddresses.Vault());

    uint value = 1;
    vault.send(value);

    Assert.equal(vault.getBalance(), value, "Manager Address should have a balance of 1");
    // Assert.equal(true, false, "ehh");
  }

    function () {
    // This will NOT be executed when Ether is sent. \o/
  }
}