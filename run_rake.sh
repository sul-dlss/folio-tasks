#!/bin/bash

# usage: ./run-rake.sh {task_name} {STAGE(defaults to dev)}

# if you want logs to go into a specific directory other than the task name,
# hard-code it here first:
DIR=""

STAGE=$2

if [ -z $DIR ]; then
  DIR="~/${1}"
fi

if [ -z $STAGE ]; then
  STAGE=dev
fi

date > ${DIR}/$1.err

STAGE=$STAGE bundle exec rake $1 > ${DIR}/$1.log 2> ${DIR}/$1.err

date >> ${DIR}/$1.err
