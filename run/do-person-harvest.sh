#!/bin/bash

if [[ -z $STAGE ]]; then
  STAGE=prod
fi

HOME=/s/SUL/Bin/folio-tasks/current
LOG=$HOME/log
OUT=$HOME/out
KEYS=$2
DATE=$3

# Run the registry harvest
if [[ $1 == 'file' ]]; then
  $HOME/run/person-file-load.sh $KEYS
else
  $HOME/run/person-runonce.sh
fi

if [[ -z $DATE ]]; then
  DATE=`date +%Y%m%d%H%M`
fi

# Remove carriage returns from the log
sed -i '/\r/d' $LOG/harvest.log

# Run harvest.xml.out through folio_api_client ruby script to load users into FOLIO
$HOME/run/folio-userload.sh

# Run folio-user.log through illiad web plartform api to load users into ILLiad
$HOME/run/illiad-userload.sh

# Email and move/reset work files
cat $LOG/harvest.log | mailx -s 'Harvest Log' sul-unicorn-devs@lists.stanford.edu

# Save output files
mv $OUT/harvest.xml.out $OUT/harvest.xml.out.$DATE

# Save and reset log files
mv $LOG/harvest.log $LOG/harvest.log.$DATE
mv $LOG/illiad.log $LOG/illiad.log.$illiad_date.$DATE

touch $LOG/harvest.log
touch $LOG/illiad.log

usage(){
    echo "Usage: $0 [ no argument | 'file' ] [ file of user keys (if arg0 == file) ] [ DATE (optional: to append to log and out files) ]"
    exit 1
}

[[ $0 =~ "help" ]] && usage
