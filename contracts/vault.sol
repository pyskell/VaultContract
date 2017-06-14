pragma solidity ^0.4.10;
// import * from "./config.sol";

/// @title Managed Withdrawal - Vault Contract

/// This contract receives instructions from another address on what to transfer
/// But it restricts transfers to hardcoded limits which are defined at contract creation

/// Ideally this contract would be created and then have its private key destroyed (or stored securely offline)
/// The goal is to provide piece of mind that someone obtaining the private key of the Manager Address could not
/// immediately drain the Vault Contract address of all its value.

/// In the event the Manager Address is comprimised, any holder of the private key can call the panicTransfer()
/// Function which will empty out the Vault Contract into a pre-defined wallet.

contract Vault {
	// address constant _managerAddress;
	// TODO: Maybe allow for the _panicAddress to be encrypted.
	// address constant _panicAddress;

	mapping (address => uint) managerBalances;
	mapping (address => address) panicAddresses;

	mapping (address => uint) lastTransferTimes;
	/// The minimum number of seconds you want to pass before allowing the next withdrawal.
	mapping (address => uint) timeLimits;
	/// The maximum amount of ETC you want withdrawn per withdrawal.
	mapping (address => uint) valueLimits;

	event PanicTransfer(address sender, bool success);
	event Withdrawal(address sender, uint value, bool success);

	function Vault(address panicAddress, uint timeLimit, uint valueLimit){
		// block.timestamp can have an error of 900 seconds so to be safe we don't allow very short timeLimits
		if (timeLimit < 900) {throw;}
		if (valueLimit == 0) {throw;}

		managerBalances[msg.sender] = msg.sender.balance;
		panicAddresses[msg.sender] = panicAddress;
		timeLimits[msg.sender] = timeLimit;
		valueLimits[msg.sender] = valueLimit;
	}

	/// Dump the remaining balance to a pre-programmed safe address that does not include a balance.
	/// You MUST have the private key to this address.
	function panicTransfer(){
		uint managerBalance = managerBalances[msg.sender];
		if (managerBalance > 0 && this.balance >= managerBalance){
			// TODO: Do I need to include gas? Or does this max out gas?
			panicAddresses[msg.sender].transfer(managerBalance);
			PanicTransfer(msg.sender, true);
			// return true;
		} else{
			PanicTransfer(msg.sender, false);
			throw; // Use up the gas of the illegitimate caller.
		}

	}

	/// Track a deposit from the sender's account
	function() payable {
		managerBalances[msg.sender] += msg.value;
	}
	
	/// Make a deposit into a specific account.
	function deposit(address from) payable {
		managerBalances[from] += msg.value;
	}

	/// Withdraw a specified balance provided that the correct address is requesting it and it's within the withdrawal limits
	function withdraw(uint value) returns (bool){
		// if (managerBalances[msg.sender] == 0){
		// 	Withdrawal(msg.sender, value, false);
		// 	return false;
		// }

		uint managerBalance = managerBalances[msg.sender];
		bool timeLimitAllowed = block.timestamp > lastTransferTimes[msg.sender] + timeLimits[msg.sender];
		bool valueAllowed = value <= valueLimits[msg.sender];
		bool enoughBalance = managerBalance > 0 && this.balance >= managerBalance;

		if (timeLimitAllowed && valueAllowed && enoughBalance){
			// TODO: There's no guarantee that the transfer will go through on the current block.
			// TODO: Need to decide if that is important or not.
			managerBalances[msg.sender] -= value;
			lastTransferTimes[msg.sender] = block.timestamp;
			msg.sender.transfer(value);

			Withdrawal(msg.sender, value, true);
			return true;
		} else{
			Withdrawal(msg.sender, value, false);			
			return false;
		}
	}

	function getBalance() returns (uint) {
		return managerBalances[msg.sender];
	}
}