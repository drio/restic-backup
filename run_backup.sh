#!/bin/bash
set -e

source .env
k=$1

if [[ $k != "b2" && $k != "teewinot-wd" ]];then
  echo "only: b2 or teewinot-wd"
  exit 0
fi

if [ $k == "b2" ];then
  export $B2_VARS 
  restic -r $B2_URL backup $INCLUDE $PASS_FILE $EXCLUDE > ${k}.log
else 
  restic -r $HOST:$REPO_DIR_WD backup $INCLUDE $PASS_FILE $EXCLUDE > ${k}.log
fi
./metrics.sh ./${k}.log type="\"drio-${k}\"" > metrics.$k
scp ./metrics.$k $NODE_EXPORTER_SSH:$NODE_EXPORTER_DIR/metrics.drio.${k}.prom
rm -f metrics.$k ${k}.log
