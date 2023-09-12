#!/bin/bash

source $(dirname $0)/harvest.env

[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm" # Load RVM into a shell session *as a function*

cd $HARVEST_HOME
STAGE=$STAGE bundle exec rake illiad:fetch_and_load_users[$1] > $LOG/illiad-userload.log 2>&1

cat $LOG/illiad-userload.log | mailx -s 'ILLiad Userload Errors' sul-unicorn-devs@lists.stanford.edu
