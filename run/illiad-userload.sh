#!/bin/bash

source harvest.env

cd $HARVEST_HOME
STAGE=$STAGE bundle exec rake illiad:fetch_and_load_users > $LOG/illiad-userload.log 2>&1
