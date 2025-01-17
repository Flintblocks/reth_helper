#!/bin/bash

current_directory="$(dirname "$(readlink -f "$0")")"
IFS="/" read -ra dir_array <<< "${current_directory#/}"  # Remove leading slash
parsed_dir="/${dir_array[0]}/${dir_array[1]}/${dir_array[2]}"
source "${parsed_dir}/scripts/load_variables.sh"
source "${parsed_dir}/scripts/get_os_arch.sh"

sudo RUST_LOG=info /$BASE_DIR/$NODE_CLIENT/$NODE_CLIENT node --datadir=/$BASE_DIR/$NODE_CLIENT/data --chain=mainnet --metrics=5005 --port=30303 --http --ws --log.persistent --log.directory=/$BASE_DIR/$NODE_CLIENT/logs/