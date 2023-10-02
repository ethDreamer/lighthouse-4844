#!/bin/bash

export ETH_TESTNET=devnet-9

export EXECUTION_NODE=geth # can be [geth|nethermind]
export CONSENSUS_DISC=9003  # discovery TCP/UDP port open to internet for lighthouse
export EXECUTION_DISC=30306 # discovery TCP/UDP port open to internet for execution node

# metrics settings
export PROMETHEUS_PORT=9090 # port to serve prometheus front-end
export GRAFANA_PORT=3000    # port to serve grafana front-end



