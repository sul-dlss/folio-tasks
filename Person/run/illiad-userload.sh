#!/bin/bash

source $(dirname $0)/harvest.env

[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [ -z $1 ]; then
  folio_users=$LOG/folio-user.log
else
  folio_users=$LOG/folio-user.log.$1
fi

cd $HARVEST_HOME

java -jar target/Person-jar-with-dependencies.jar $folio_users >> $LOG/illiad-userload.log  2>> $LOG/illiad-err.log

# Remove carriage returns from the log
sed -i 's/\r//g' $LOG/illiad-userload.log

cat $LOG/illiad-userload.log | sed '/\n/d' | mailx -s 'ILLiad Userload Logs' sul-unicorn-devs@lists.stanford.edu
cat $LOG/illiad-err.log | mailx -s 'ILLiad Userload Errors' sul-unicorn-devs@lists.stanford.edu
