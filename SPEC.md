# Order Message 
| Name       | Data Type | Description                                                 |
|------------|-----------|-------------------------------------------------------------|
| version    | address   | Address of the DEX smart contract.                          |
| maker      | address   | Address originating the order.                              |
| taker      | address   | Address permitted to fill the order. (Optional)             |
| chainA     | uint256   | Chain ID of an ERC20 Token contract.                        |
| tokenA     | address   | Address of an ERC20 Token contract.                         |
| valueA     | uint256   | Total units of tokenA offered by maker                      |
| chainB     | uint256   | Chain ID of an ERC20 Token contract.                        |
| tokenB     | address   | Address of an ERC20 Token contract.                         |
| valueB     | uint256   | Total units of tokenB requested by maker.                   |
| expiration | uint256   | Time at which the order expires (seconds since unix epoch). |
| v          | uint8     | ECDSA signature of the above arguments.                     |
| r          | bytes32   |                                                             |
| s          | bytes32   |                                                             |

# DEX Smart Contract

## Signature

## Fill
