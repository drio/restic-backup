#!/bin/bash
set -e

source .env
k=$1

if [[ $k != "b2" && $k != "wd" && $k != "ds720" && $k != "reolink" ]];then
  echo "only: b2, wd, reolink or ds720"
  exit 0
fi

if [ $k == "b2" ];then
  export $B2_VARS
  restic -r $B2_URL backup $INCLUDE $PASS_FILE $EXCLUDE > ${k}.log
elif [ $k == "ds720" ];then
  restic -r $DS720_REPO_DIR backup $INCLUDE $PASS_FILE $EXCLUDE > ${k}.log
elif [ $k == "reolink" ];then
  export B2_ACCOUNT_ID=$REOLINK_B2_ID
  export B2_ACCOUNT_KEY=$REOLINK_B2_KEY
  restic -r b2:$REOLINK_B2_BUCKET backup  /Volumes/ftp-reolink "--password-file=./pass.reolink.txt" > ${k}.log
else
  restic -r $WD_REPO_DIR backup $INCLUDE $PASS_FILE $EXCLUDE > ${k}.log
fi

./metrics.sh ./${k}.log type="\"drio-${k}\"" > metrics.$k
echo "Metrics sent for $k:"
cat metrics.$k
ssh $NODE_EXPORTER_SSH "rm -f $NODE_EXPORTER_DIR/metrics.drio.${k}.prom"
scp ./metrics.$k $NODE_EXPORTER_SSH:$NODE_EXPORTER_DIR/metrics.drio.${k}.prom
rm -f metrics.$k ${k}.log
