#!/bin/bash

TESTNET_DIR=/shared/4844-testnet/network-configs/${ETH_TESTNET}


if [ "$METRICS_ENABLED" = "true" ]; then
    METRICS_ARG="--Metrics.Enabled true --Metrics.ExposePort=6060"
fi

BOOTFILE=${TESTNET_DIR}/bootnode.txt
if [ -e ${BOOTFILE} ]; then
    BOOTARG="--Discovery.Bootnodes=$(cat ${BOOTFILE} | tr '\n' ',' | sed 's/,\s*$//')"
fi

echo "******************** STARTING NETHERMIND ********************"


exec /nethermind/nethermind \
    --config=none.cfg \
    --Init.ChainSpecPath=${TESTNET_DIR}/chainspec.json \
    --Init.IsMining=false \
    --Pruning.Mode=None \
    --datadir="./datadir" \
    --JsonRpc.Enabled=true \
    --JsonRpc.EnabledModules="net,eth,consensus,subscribe,web3,admin,rpc,parity" \
    --JsonRpc.Port=8545 \
    --JsonRpc.Host=0.0.0.0 \
    --Network.DiscoveryPort=${EXECUTION_DISC} \
    --Network.P2PPort=${EXECUTION_DISC} \
    --JsonRpc.JwtSecretFile=/shared/jwt.secret \
    --Mev.Enabled=true \
    --JsonRpc.AdditionalRpcUrls="http://0.0.0.0:8560|http;ws|engine;eth;net;subscribe;web3;client;parity" \
    --TxPool.BlobSupportEnabled=true \
    --TxPool.PersistentBlobStorageEnabled=true \
    --TxPool.ReportMinutes=5 \
    $BOOTARG \
    $METRICS_ARG

