#!/bin/bash

DATE=`date +%Y%m%d%H%M`
# HOME=/s/SUL/Bin/folio-tasks/current
HOME=./
LOG=$HOME/log
OUT=$HOME/out

if [[ -z $STAGE ]]; then
  STAGE=prod
fi

[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm" # Load RVM into a shell session *as a function*

cd $HOME
STAGE=$STAGE bundle exec rake illiad:fetch_and_load_users > $LOG/illiad-userload.log 2>&1

mv $LOG/illiad-userload.log $LOG/illiad-userload.log.$DATE
touch $LOG/illiad-userload.log
