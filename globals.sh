#!/bin/bash

export ETH_TESTNET=devnet-9

export EXECUTION_NODE=geth # can be [geth|nethermind]
export CONSENSUS_DISC=9003  # discovery TCP/UDP port open to internet for lighthouse
export EXECUTION_DISC=30306 # discovery TCP/UDP port open to internet for execution node

# metrics settings
export PROMETHEUS_PORT=9090 # port to serve prometheus front-end
export GRAFANA_PORT=3000    # port to serve grafana front-end

# image / container names
# set these to change the prefix of the images / containers
# if ETH_TESTNET is "devnet-9", the default prefix will be "devnet9"
export IMAGE_PREFIX="${ETH_TESTNET//-/}"
export CONTAINER_PREFIX="${ETH_TESTNET//-/}"

# permissions
#
# By default, the containers will run with the same credentials as the current user
# Uncomment the lines below to customize the credentials of the processes
#
# credentials for beacon node process
# BEACON_UID=1000
# BEACON_GID=1000
# credentials for execution node process
# EXECUTION_UID=1000
# EXECUTION_GID=1000
# credentials for prometheus / grafana processes
# METRICS_UID=1000
# METRICS_GID=1000

USER_UID=$(id -u)
USER_GID=$(id -g)

export BEACON_UID=${BEACON_UID:-$USER_UID}
export BEACON_GID=${BEACON_GID:-$USER_GID}
export EXECUTION_UID=${EXECUTION_UID:-$USER_UID}
export EXECUTION_GID=${EXECUTION_GID:-$USER_GID}
export METRICS_UID=${METRICS_UID:-$USER_UID}
export METRICS_GID=${METRICS_GID:-$USER_GID}

check_permissions() {
  local user_uid=$1
  local user_gid=$2
  local directory=$3
  local context=$4

  if [ ! -d "$directory" ]; then
    echo "WARNING: $context - Directory $directory does not exist."
    return
  fi

  local dir_stats=$(stat -c "%u %g %a" "$directory")
  read -r dir_uid dir_gid dir_perms <<< "$dir_stats"

  local user_perms=$(( dir_perms / 100 ))
  local group_perms=$(( (dir_perms / 10) % 10 ))
  local other_perms=$(( dir_perms % 10 ))

  local user_has_read=$(( user_perms / 4 ))
  local user_has_write=$(( (user_perms / 2) % 2 ))
  local user_has_execute=$(( user_perms % 2 ))

  if [ "$user_uid" -ne "$dir_uid" ]; then
    if [ "$user_gid" -eq "$dir_gid" ]; then
      user_has_read=$(( group_perms / 4 ))
      user_has_write=$(( (group_perms / 2) % 2 ))
      user_has_execute=$(( group_perms % 2 ))
    else
      user_has_read=$(( other_perms / 4 ))
      user_has_write=$(( (other_perms / 2) % 2 ))
      user_has_execute=$(( other_perms % 2 ))
    fi
  fi

  if [ "$user_has_read" -eq "0" ] || [ "$user_has_write" -eq "0" ] || [ "$user_has_execute" -eq "0" ]; then
    missing=""
    [ "$user_has_read" -eq "0" ] && missing="read"
    [ "$user_has_write" -eq "0" ] && [ -n "$missing" ] && missing="$missing,write" || [ -z "$missing" ] && missing="write"
    [ "$user_has_execute" -eq "0" ] && [ -n "$missing" ] && missing="$missing,execute" || [ -z "$missing" ] && missing="execute"
    echo "WARNING: $context - User $user_uid:$user_gid does NOT have $missing permissions on $directory."
  fi
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

check_permissions $BEACON_UID $BEACON_GID $SCRIPT_DIR/lighthouse/beacon/run "Lighthouse Beacon"
check_permissions $EXECUTION_UID $EXECUTION_GID $SCRIPT_DIR/$EXECUTION_NODE/run $EXECUTION_NODE
check_permissions $METRICS_UID $METRICS_GID $SCRIPT_DIR/metrics/run/grafana "Metrics"
check_permissions $METRICS_UID $METRICS_GID $SCRIPT_DIR/metrics/run/prometheus "Metrics"

