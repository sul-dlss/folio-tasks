#!/bin/bash

source harvest.env

batch=0
# Split $HARVEST (harvest.xml.out) file into batches of 100 and run through folio_user script >
while mapfile -t -n 100 array && ((${#array[@]}))
do
    let batch=batch+1
    printf '%s\n' "${array[@]}" > $OUT/tmp.xml
    STAGE="${STAGE}" ruby $HARVEST_HOME/bin/folio_user.rb $OUT/tmp.xml $batch >> $LOG/folio-user.log 2>> $LOG/folio-err.log
    rm $OUT/tmp.xml
done < $HARVEST

STAGE="${STAGE}" rake users:deactivate_users > $LOG/folio-inactive.log 2>&1

cat $LOG/folio-err.log | mailx -s 'Folio Userload: Inactive Users' sul-unicorn-devs@lists.stanford.edu

cat $LOG/user-import-response.log | egrep 'batch|Loading|message|createdRecords|updatedRecords|failedRecords|failedUsers|errorMessage|totalRecords' | mailx -s "Folio Userload: Summary for folio.log.$DATE" sul-unicorn-devs@lists.stanford.edu

cat $LOG/folio-inactive.log | egrep 'message|createdRecords|updatedRecords|failedRecords|failedUsers|errorMessage|totalRecords' | mailx -s "Folio Userload: Deactivated Users Summary for folio-inactive.log.$DATE" sul-unicorn-devs@lists.stanford.edu

# Save and reset log files
mv $LOG/folio-user.log $LOG/folio-user.log.$DATE
mv $LOG/folio-err.log $LOG/folio-err.log.$DATE
mv $LOG/folio-inactive.log $LOG/folio-inactive.log.$DATE
mv $LOG/user-import-response.log $LOG/user-import-response.log.$DATE

touch $LOG/folio-user.log
touch $LOG/folio-err.log
touch $LOG/folio-inactive.log

usage(){
    echo "Usage: $0 [ no argument | full path to xml.out file ]"
    exit 1
}

[[ $1 =~ "help" ]] && usage
