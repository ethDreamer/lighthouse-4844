#!/bin/bash

export ETH_TESTNET=devnet-11

export EXECUTION_NODE=nethermind # can be [geth|nethermind|besu|reth]
export CONSENSUS_DISC=9000  # discovery TCP/UDP port open to internet for lighthouse
export EXECUTION_DISC=30303 # discovery TCP/UDP port open to internet for execution node

# metrics settings
export PROMETHEUS_PORT=9090 # port to serve prometheus front-end
export GRAFANA_PORT=3000    # port to serve grafana front-end

# image / container names
# set these to change the prefix of the images / containers
# if ETH_TESTNET is "devnet-9", the default prefix will be "devnet9"
export IMAGE_PREFIX="${ETH_TESTNET//-/}"
export CONTAINER_PREFIX="${ETH_TESTNET//-/}"

# docker images
export LIGHTHOUSE_IMAGE=sigp/lighthouse:latest-unstable
export GETH_IMAGE=ethpandaops/geth:lightclient-devnet-10-4d161de
export BESU_IMAGE=hyperledger/besu:develop
export NETHERMIND_IMAGE=ethpandaops/nethermind:master-4847b06
export RETH_IMAGE=ethdreamer/reth:main-e0276d2

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

  if [ "$user_uid" -eq "0" ]; then
    return # root user bypasses permission checks
  fi

  if [ ! -d "$directory" ]; then
    echo "WARNING: $context - Directory $directory does not exist."
    return
  fi

  local dir_uid dir_gid dir_perms platform
  platform=$(uname)

  if [[ "$platform" == "Darwin" ]]; then
    # Fetch user and group name and then convert to ID
    local owner_name=$(stat -f "%Su" "$directory")
    local group_name=$(stat -f "%Sg" "$directory")

    # Convert owner name to UID, if it's not a number already
    if [[ "$owner_name" =~ ^[0-9]+$ ]]; then
      dir_uid=$owner_name
    else
      dir_uid=$(id -u "$owner_name" 2>/dev/null)
      [[ -z $dir_uid ]] && echo "WARNING: No user ID found for owner $owner_name. Using 0 as a fallback." && dir_uid=0
    fi

    # Convert group name to GID, if it's not a number already
    if [[ "$group_name" =~ ^[0-9]+$ ]]; then
      dir_gid=$group_name
    else
      dir_gid=$(dscl . -read "/Groups/$group_name" | awk '/PrimaryGroupID:/{print $2}' 2>/dev/null)
      [[ -z $dir_gid ]] && echo "WARNING: No group ID found for group $group_name. Using 0 as a fallback." && dir_gid=0
    fi

    # Use the '%A' format for numeric access rights on macOS
    dir_perms=$(stat -f "%A" "$directory")
  else
    # On Linux, use 'stat' to get IDs and permissions directly
    read -r dir_uid dir_gid dir_perms <<< $(stat -c "%u %g %a" "$directory")
  fi

  # Calculate the effective permissions considering user, group, and others
  local effective_read=0 effective_write=0 effective_execute=0

  # Parse permissions to a user-readable format, considering ownership and group membership
  local user_bit=$(( dir_perms / 100 ))
  local group_bit=$(( (dir_perms / 10) % 10 ))
  local other_bit=$(( dir_perms % 10 ))

  # Check for user permissions if the user is the owner
  if [ "$user_uid" -eq "$dir_uid" ]; then
    effective_read=$(( user_bit & 4 ))
    effective_write=$(( user_bit & 2 ))
    effective_execute=$(( user_bit & 1 ))
  fi

  # Check for group permissions if the user is not the owner but belongs to the group
  if [ "$user_gid" -eq "$dir_gid" ]; then
    effective_read=$(( effective_read | (group_bit & 4) ))
    effective_write=$(( effective_write | (group_bit & 2) ))
    effective_execute=$(( effective_execute | (group_bit & 1) ))
  fi

  # Lastly, apply 'other' permissions for all users
  effective_read=$(( effective_read | (other_bit & 4) ))
  effective_write=$(( effective_write | (other_bit & 2) ))
  effective_execute=$(( effective_execute | (other_bit & 1) ))

  # Based on effective permissions, generate warning messages
  local missing=""
  [ "$effective_read" -eq "0" ] && missing+="read "
  [ "$effective_write" -eq "0" ] && missing+="write "
  [ "$effective_execute" -eq "0" ] && missing+="execute"

  if [ -n "$missing" ]; then
    echo "WARNING: $context - User $user_uid:$user_gid does NOT have $(echo $missing | xargs) permissions on $directory."
  fi
}


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

check_permissions $BEACON_UID $BEACON_GID $SCRIPT_DIR/lighthouse/beacon/run "Lighthouse Beacon"
check_permissions $EXECUTION_UID $EXECUTION_GID $SCRIPT_DIR/$EXECUTION_NODE/run $EXECUTION_NODE
check_permissions $METRICS_UID $METRICS_GID $SCRIPT_DIR/metrics/run/grafana "Metrics"
check_permissions $METRICS_UID $METRICS_GID $SCRIPT_DIR/metrics/run/prometheus "Metrics"

