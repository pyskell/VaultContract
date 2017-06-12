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
	address constant _managerAddress = 0;
	// TODO: Maybe allow for the _panicAddress to be encrypted.
	address constant _panicAddress = 0;
	uint _lastTransferTime = 0;

	/// The minimum number of seconds you want to pass before allowing the next withdrawal.
	uint constant _timeLimit = 3600;
	/// The maximum amount of ETC you want withdrawn per withdrawal.
	uint constant _valueLimit = 1;

	event PanicTransfer(address sender, bool success);
	event Withdrawal(address sender, uint value, bool success);

	function Vault(){
		// block.timestamp can have an error of 900 seconds so to be safe we don't allow very short timeLimits
		if (_timeLimit < 900) {throw;}
		if (_valueLimit == 0) {throw;}
	}

	/// Dump the remaining balance to a pre-programmed safe address that does not include a balance.
	/// You MUST have the private key to this address.
	function panicTransfer() returns (bool){
		if (this.balance > 0){
			// TODO: Do I need to include gas? Or does this max out gas?
			_panicAddress.transfer(this.balance);
			PanicTransfer(msg.sender, true);
			return true;
		}

		PanicTransfer(msg.sender, false);
		throw; // Use up the gas of the illegitimate caller.
	}

	/// Withdraw a specified balance provided that the correct address is requesting it and it's within the withdrawal limits
	function withdraw(uint value) returns (bool){
		if (msg.sender != _managerAddress){
			Withdrawal(msg.sender, value, false);
			return false;
		}

		bool blockAllowed = block.timestamp > _lastTransferTime + _timeLimit;
		bool valueAllowed = value <= _valueLimit;
		bool enoughBalance = this.balance >= value;

		if (blockAllowed && valueAllowed && enoughBalance){
			// TODO: There's no guarantee that the transfer will go through on the current block.
			// TODO: Need to decide if that is important or not.
			_lastTransferTime = block.timestamp;
			_managerAddress.transfer(value);

			Withdrawal(msg.sender, value, true);
			return true;
		} else{
			Withdrawal(msg.sender, value, false);			
			return false;
		}
	}
}