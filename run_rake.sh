#!/bin/bash

# usage: ./run-rake.sh {task_name} {STAGE(defaults to dev)}

STAGE=$2
DIR=$3

usage(){
    echo "Usage: $0 {task_name} {STAGE} {output dir | .}"
    exit 1
}

[[ $1 =~ "help" || $@ < 1 ]] && usage

if [ -z $DIR ]; then
  DIR="~/${1}"
fi

date > ${DIR}/$1.err

STAGE=$STAGE bundle exec rake $1 > ${DIR}/$1.log 2> ${DIR}/$1.err

date >> ${DIR}/$1.err
