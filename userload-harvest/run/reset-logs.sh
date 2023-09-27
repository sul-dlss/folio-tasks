#!/bin/bash

source $(dirname $0)/harvest.env

# Save and reset log files
mv $LOG/harvest.log $LOG/harvest.log.$DATE
mv $LOG/userload.log $LOG/userload.log.$DATE
mv $LOG/userload-err.log $LOG/userload-err.log.$DATE
mv $LOG/folio-inactive.log $LOG/folio-inactive.log.$DATE
mv $LOG/user-import-response.log $LOG/user-import-response.log.$DATE

touch $LOG/harvest.log
touch $LOG/userload.log
touch $LOG/userload-err.log
touch $LOG/folio-inactive.log
touch $LOG/user-import-response.log
