#!/bin/bash

TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}

BOOTFILE=${TESTNET_DIR}/bootnode.txt
if [ -e $BOOTFILE ]; then
    BOOT_ARG="--bootnodes=$(shuf -n 10 $BOOTFILE | tr '\n' ',' | sed 's/,\s*$//')"
fi

GENFILE=${TESTNET_DIR}/genesis.json
if [ -e $GENFILE ]; then
    CHAIN_ARG="--chain=$GENFILE"
fi

if [ "$METRICS_ENABLED" = "true" ]; then
    METRICS_ARG="--metrics=0.0.0.0:6060"
fi

export WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "******************** STARTING RETH ********************"
echo "WAN IP: $WANIP"

exec reth node \
    --datadir=./datadir \
    --log.file.directory=./datadir/logs \
    --port=$EXECUTION_DISC \
    --discovery.port=$EXECUTION_DISC \
    --http \
    --http.addr=0.0.0.0 \
    --http.port=8545 \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port=8560 \
    --authrpc.jwtsecret=/shared/jwt.secret \
    --nat=extip:$WANIP \
    $METRICS_ARG \
    $CHAIN_ARG \
    --http.api=eth,net,web3,debug,admin,txpool,rpc \
    $BOOT_ARG



