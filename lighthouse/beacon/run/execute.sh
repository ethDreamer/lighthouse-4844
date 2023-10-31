#!/bin/bash

TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}

if [ "$METRICS_ENABLED" = "true" ]; then
    METRICS_ARG="--metrics --metrics-address=0.0.0.0 --metrics-allow-origin=*"
fi

if [ "$PROXY_ENABLED" = "true" ]; then
    EE_TARGET="http://proxy:8560"
else
    EE_TARGET="http://execution:8560"
fi

if [ "$MEVBOOST_ENABLED" = "true" ]; then
    BUILDER_ARG="--builder=http://mev-boost:8560"
fi


BOOTFILE=${TESTNET_DIR}/bootstrap_nodes.txt
if [ -e $BOOTFILE ]; then
    BOOT_ARG="--boot-nodes=$(shuf -n 10 $BOOTFILE | tr '\n' ',' | sed 's/,\s*$//')"
fi

echo "******************** STARTING LIGHTHOUSE BEACON NODE ********************"

exec lighthouse \
    --log-color \
    --debug-level=info \
    --datadir ./datadir \
    --testnet-dir=$TESTNET_DIR \
    beacon \
    --eth1 \
    $BOOT_ARG \
    --http \
    --http-address=0.0.0.0 \
    --http-allow-sync-stalled \
    --disable-packet-filter \
    --discovery-port $CONSENSUS_DISC \
    --port $CONSENSUS_DISC \
    $(printf '%s' "$METRICS_ARG") \
    --execution-jwt=/shared/jwt.secret \
    --execution-endpoint=$EE_TARGET \
    --self-limiter=blob_sidecars_by_range:256/10 \
    --disable-peer-scoring \
    $BUILDER_ARG


