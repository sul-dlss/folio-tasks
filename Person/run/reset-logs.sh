#!/bin/bash

source $(dirname $0)/harvest.env

# Save and reset log files
mv $LOG/harvest.log $LOG/harvest.log.$DATE
mv $LOG/illiad-userload.log $LOG/illiad-userload.log.$DATE
mv $LOG/folio-user.log $LOG/folio-user.log.$DATE
mv $LOG/folio-err.log $LOG/folio-err.log.$DATE
mv $LOG/folio-inactive.log $LOG/folio-inactive.log.$DATE
mv $LOG/user-import-response.log $LOG/user-import-response.log.$DATE

touch $LOG/folio-user.log
touch $LOG/folio-err.log
touch $LOG/folio-inactive.log
touch $LOG/harvest.log
touch $LOG/illiad-userload.log
touch $LOG/user-import-response.log