#!/bin/bash

set -e
set -u
[ -n "${DEBUG:-}" ] && set -x || true

mkdir -p "$HOME/.cita-cli"
eval "data=$(cita-cli ethabi encode function contracts/tokens_sol_FixedSupplyToken.abi transferAnyERC20Token --param $ADDR --param $VAL)"
echo $data

cita-cli rpc sendRawTransaction --private-key $PK --code "0x$data" --address "$ERC20" --chain-id 1
