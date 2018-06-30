abi:
	cd contracts && solcjs --abi exchange.sol
	cd contracts && solcjs --abi tokens.sol

.PHONY: abi

