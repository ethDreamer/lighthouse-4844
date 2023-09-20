#!/bin/sh

TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}

BOOTFILE=${TESTNET_DIR}/bootnode.txt
if [ -e $BOOTFILE ]; then
	BOOT_ARG="--bootnodes=$(cat $BOOTFILE | sed 's/\s\+//g' | tr '\n' ',' | sed 's/,\s*$//')"
fi

GENFILE=${TESTNET_DIR}/genesis.json
if [ -e $GENFILE ]; then
    NET_ARG="--networkid=$(cat $GENFILE | grep chainId | awk '{ print $2 }' | sed 's/,//g')"
    if [ ! -e ./datadir ]; then
        echo "**** INITIALIZING DATADIR FROM GENESIS FILE ****"
        echo "$GENFILE"
        geth --datadir ./datadir init $GENFILE
        echo "**** INITIALIZING DATADIR FROM GENESIS FILE ****"
    fi
fi

if [ "$METRICS_ENABLED" = "true" ]; then
    METRICS_ARG="--metrics --metrics.addr=0.0.0.0"
fi

echo "******************** STARTING GETH ********************"

exec geth \
    --datadir ./datadir \
    --http \
    --http.addr 0.0.0.0 \
    --http.api="engine,eth,web3,net,debug,admin" \
    --http.vhosts=\* \
    --port $EXECUTION_DISC \
    $NET_ARG \
    $BOOT_ARG \
    --syncmode full \
    --verbosity=3 \
    --authrpc.addr 0.0.0.0 \
    --authrpc.port 8560 \
    --authrpc.vhosts \* \
    --authrpc.jwtsecret=/shared/jwt.secret \
    $METRICS_ARG \

