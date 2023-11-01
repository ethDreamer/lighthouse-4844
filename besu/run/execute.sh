#!/bin/bash

TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}

BOOTFILE=${TESTNET_DIR}/bootnode.txt
if [ -e $BOOTFILE ]; then
    BOOT_ARG="--bootnodes=$(cat $BOOTFILE | tr '\n' ',' | sed 's/,\s*$//')"
fi

GENFILE=${TESTNET_DIR}/besu.json
if [ -e $GENFILE ]; then
    NET_ARG="--network-id=$(cat $GENFILE | grep chainId | awk '{ print $2 }' | sed 's/,//g')"
    GEN_ARG="--genesis-file=$GENFILE"
fi

if [ "$METRICS_ENABLED" = "true" ]; then
    METRICS_ARG="--metrics-enabled --metrics-host=0.0.0.0 --metrics-port 6060"
fi

export WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "******************** STARTING BESU ********************"
echo "WAN IP: $WANIP"

exec besu \
    --data-path="./datadir" \
    --nat-method=NONE \
    --p2p-host=$WANIP \
    --p2p-port=$EXECUTION_DISC \
    --rpc-http-enabled \
    --rpc-http-host=0.0.0.0 \
    --rpc-http-port=8545 \
    --rpc-http-cors-origins="*" \
    --host-allowlist="*" \
    --engine-jwt-secret=/shared/jwt.secret \
    --engine-rpc-port=8560 \
    --engine-host-allowlist="*" \
    $METRICS_ARG \
    $GEN_ARG \
    $BOOT_ARG \
    --rpc-http-api="ADMIN,CLIQUE,MINER,ETH,NET,DEBUG,TXPOOL,ENGINE,TRACE,WEB3" \
    --sync-mode=FULL \
    --data-storage-format="BONSAI" \
    --kzg-trusted-setup=$TESTNET_DIR/trusted_setup.txt \
    --logging=INFO \
    --color-enabled \
    --pruning-enabled \
    --Xfilter-on-enr-fork-id=true \


