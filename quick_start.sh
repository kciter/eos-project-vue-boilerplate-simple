#!/usr/bin/env bash

# make sure everything is clean and well setup
echo "[quick_start.sh] First time setup"
./first_time_setup.sh

# start blockchain and put in background
echo "[quick_start.sh] Starting eosio docker"
./start_eosio_docker.sh --nolog

# wait until eosio blockchain to be started
until $(curl --output /dev/null \
             --silent \
             --head \
             --fail \
             localhost:8888/v1/chain/get_info)
do
  echo "Waiting eosio blockchain to be started..."
  sleep 2s
done

#start frontend vue app
echo "[quick_start.sh] Starting frontend vue app"
./start_frontend.sh
