#!/bin/bash

source $(dirname $0)/harvest.env

[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm" # Load RVM into a shell session *as a function*

cd $HARVEST_HOME/..
batch=0
# Split $HARVEST (harvest.xml.out) file into batches of 100 and run through folio_user script >
while mapfile -t -n 100 array && ((${#array[@]}))
do
    let batch=batch+1
    printf '%s\n' "${array[@]}" > $OUT/tmp.xml
    STAGE="${STAGE}" ruby bin/folio_user.rb $OUT/tmp.xml $batch >> $LOG/folio-user.log 2>> $LOG/folio-err.log
    rm $OUT/tmp.xml
done < $HARVEST

cat $LOG/folio-err.log | mailx -s 'Folio Userload Errors' sul-unicorn-devs@lists.stanford.edu
cat $LOG/user-import-response.log | mailx -s "Folio Userload: Summary for $DATE" sul-unicorn-devs@lists.stanford.edu

STAGE="${STAGE}" rake users:deactivate_users > $LOG/folio-inactive.log 2>&1

cat $LOG/folio-inactive.log | egrep 'message|createdRecords|updatedRecords|failedRecords|failedUsers|errorMessage|totalRecords' | mailx -s "Folio Userload: Deactivated Users Summary for folio-inactive.log.$DATE" sul-unicorn-devs@lists.stanford.edu

usage(){
    echo "Usage: $0 [ no argument | full path to xml.out file ]"
    exit 1
}

[[ $1 =~ "help" ]] && usage
