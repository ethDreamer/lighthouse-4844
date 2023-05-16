# lighthouse-4844

A docker-compose setup for running lighthouse with different execution clients on different 4844 testnets.

## How to use

Clone the repository along with submodules for latest testnets:
```
git clone --recurse-submodules https://github.com/ethDreamer/lighthouse-4844.git
```

Ensure you have the latest copy of 4844-testnet:
```
cd lighthouse-4844 && git submodule update --remote
```

#### Set Variables in `globals.sh`

- `ETH2_TESTNET`   # the name of the testnet directory to use (see directories in `./shared/4844-testnet`)
- `EXECUTION_NODE` # pick between ~~geth~~, ~~besu~~, or `nethermind`
- `CONSENSUS_DISC` # the discovery port (TCP/UDP) for lighthouse (should be accessible from internet)
- `EXECUTION_DISC` # the discovery port (TCP/UDP) for execution node (should be accessible from internet)

After editing these be sure to run:
```
source ./globals.sh
```

#### Start the nodes

To enable only the base (consensus/execution/validator) nodes, simply run:
```
docker-compose -f beacon.yml -f execution.yml up -d
```


