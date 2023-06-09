#!/bin/bash
#
TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}


BOOTFILE=${TESTNET_DIR}/bootstrap_nodes.txt
if [ -e $BOOTFILE ]; then
    BOOT_ARG="--boot-nodes=$(cat $BOOTFILE | tr '\n' ',' | sed 's/,\s*$//')"
fi

lighthouse \
    --log-color \
    --debug-level=debug \
    --datadir ./datadir \
    --logfile ./lighthouse.log \
    beacon \
    --checkpoint-sync-url=http://localhost:6052 \
    --testnet-dir=$TESTNET_DIR \
    $BOOT_ARG \
    --disable-enr-auto-update \
    --eth1 \
    --http \
    --http-address=0.0.0.0 \
    --http-allow-sync-stalled \
    --disable-packet-filter \
    --discovery-port 9004 \
    --port 9004 \
    --execution-jwt=/shared/jwt.secret \
    --execution-endpoint=http://execution:8560

