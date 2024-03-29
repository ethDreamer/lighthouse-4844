# lighthouse-4844

A docker-compose setup for running lighthouse with different execution clients on public 4844 testnets.

## Features

- All public 4844 testnets are supported
- Major execution clients supported: geth, nethermind, besu, reth (erigon coming soon)
- All data is stored on host disk (no annoying docker volumes to deal with)
- Local directories are bind-mounted with the same permissions as the host user by default (no annoying permissions issues)
- Optional proxy between beacon and execution node for debugging
- Optional metrics gathering via prometheus and viewing with grafana
- Lots of easy configuration options set via environment variables

## Quick Start Guide

Clone this repository along with submodules for latest testnets:
```
git clone --recurse-submodules https://github.com/ethDreamer/lighthouse-4844.git
```

For best results, update to the latest version of `4844-testnet`:
```
cd lighthouse-4844 && git submodule update --remote
```

#### Set Essential Variables in `globals.sh`

The essential variables that must be set correctly before starting the containers are:

- `ETH_TESTNET`    # the name of the testnet to run (see directories in `shared/4844-testnet/network-configs`)
- `EXECUTION_NODE` # pick between geth, nethermind, besu, or reth
- `CONSENSUS_DISC` # the discovery port (TCP/UDP) for lighthouse (should be accessible from internet)
- `EXECUTION_DISC` # the discovery port (TCP/UDP) for execution node (should be accessible from internet)

After editing these be sure to run:
```
source ./globals.sh
```

Also be sure to generate a jwt token:
```
./gen-jwt.sh
```

#### Start the nodes

To enable only the necessary services (consensus/execution nodes), simply run:
```
docker compose -f beacon.yml -f execution.yml up -d
```

The yaml files are split up so that services can be swapped in as needed. There are two optional additional services:

- `metrics.yml`   # Enables prometheus metrics collection & grafana server
- `proxy.yml`     # A proxy between the beacon and execution node for debugging

These can be enabled by just adding them into the `docker compose` command. For example the proxy service can be enabled with:
```
docker compose -f beacon.yml -f execution.yml -f proxy.yml up -d
```

#### Stopping All Services

Services can be stopped in a similar fashion:
```
docker compose -f beacon.yml -f execution.yml [-f OPTIONAL SERVICES] down
```

#### Viewing Node Logs

To view the logs for each service on a continuous basis, simply run `docker logs -f [CONTAINER NAME]`.

|  Node Software  |         Container Name           |
| --------------- | -------------------------------- |
|  `lighthouse`   | `${CONTAINER_PREFIX}_beacon`     |
|     `geth`      | `${CONTAINER_PREFIX}_execution`  |
|  `nethermind`   | `${CONTAINER_PREFIX}_execution`  |
|     `besu`      | `${CONTAINER_PREFIX}_execution`  |
|     `reth`      | `${CONTAINER_PREFIX}_execution`  |
|     `proxy`     | `${CONTAINER_PREFIX}_proxy`      |
|  `prometheus`   | `${CONTAINER_PREFIX}_prometheus` |
|    `grafana`    | `${CONTAINER_PREFIX}_grafana`    |

#### Modifying Node CLI Arguments & Wiping the Data Directories

This setup was designed around making this as easy as possible for rapid development. Each service has a corresponding `run` directory on the local disk which contains an `execute.sh` script controlling how the node is launched. All data is stored inside `run/datadir` for easy removal. The `run` directory is bind mounted in the docker container (by default with the same permissions as the local user) so there are no docker volumes to wipe and no images that need to be rebuilt.

|  Node Software   |        Data Directory           |             Run Script             |
| ---------------- | ------------------------------- | ---------------------------------- |
|   `lighthouse`   | `lighthouse/beacon/run/datadir` | `lighthouse/beacon/run/execute.sh` |
|      `geth`      | `geth/run/datadir`              | `geth/run/execute.sh`              |
|   `nethermind`   | `nethermind/run/datadir`        | `nethermind/run/execute.sh`        |
|      `besu`      | `besu/run/datadir`              | `besu/run/execute.sh`              |
|      `reth`      | `reth/run/datadir`              | `reth/run/execute.sh`              |

For example, if the services are already running, and the user wishes to change the CLI options for lighthouse and restart with a fresh data directory, they would modify `lighthouse/beacon/run/execute.sh` accordingly and then run:
```
docker stop ${CONTAINER_PREFIX}_beacon && rm -rf lighthouse/beacon/run/datadir && docker start ${CONTAINER_PREFIX}_beacon
```

#### Advanced Configuration

There are additional environment variables in `globals.sh` which can be modified as needed. **Changing any of the variables listed in this section requires the docker images to be rebuilt.** There is a convenience script to remove all existing docker images (forcing a rebuild):
```
./remove-images.sh
```

Users can change the base docker image for any of the containers by setting the appropriate environment variables in `globals.sh`:

- `LIGHTHOUSE_IMAGE`
- `GETH_IMAGE`
- `BESU_IMAGE`
- `NETHERMIND_IMAGE`
- `RETH_IMAGE`

By default, the processes will be run with the same credentials as the user that sources `globals.sh`. These credentials can be controlled individually by setting the following variables in `globals.sh`:

- `BEACON_UID`
- `BEACON_GID`
- `EXECUTION_UID`
- `EXECUTION_GID`
- `METRICS_UID`
- `METRICS_GID`

The names of the images & containers generated by `docker-compose` can also be changed using the variables:

- `IMAGE_PREFIX`
- `CONTAINER_PREFIX`

This is useful when running multiple instances of this compose setup on the same machine.

Again be sure to run `source ./globals.sh` after modifying any of these variables.
