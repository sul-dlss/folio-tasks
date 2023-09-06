#!/bin/bash

source $(dirname $0)/harvest.env

if [[ -n $2 ]]; then
  KEYS=$2
fi

if [[ -n $3 ]]; then
  DATE=$3
fi

# Run the registry harvest
if [[ $1 == 'file' ]]; then
  $HARVEST_HOME/run/person-file-load.sh $KEYS
else
  $HARVEST_HOME/run/person-runonce.sh
fi

# Remove carriage returns from the log
sed -i '/\r/d' $LOG/harvest.log

# Run harvest.xml.out through folio_api_client ruby script to load users into FOLIO
$HARVEST_HOME/run/folio-userload.sh

# Run folio-user.log through illiad web plartform api to load users into ILLiad
$HARVEST_HOME/run/illiad-userload.sh

# Email and move/reset work files
cat $LOG/harvest.log | mailx -s 'Harvest Log' sul-unicorn-devs@lists.stanford.edu

# Save output files
mv $OUT/harvest.xml.out $OUT/harvest.xml.out.$DATE

$HARVEST_HOME/run/reset-logs.sh

usage(){
    echo "Usage: $0 [ no argument | 'file' ] [ file of user keys (if arg0 == file) ] [ DATE (optional: to append to log and out files) ]"
    exit 1
}

[[ $0 =~ "help" ]] && usage
