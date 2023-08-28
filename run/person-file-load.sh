#!/bin/sh
#$Id: fileLoad.sh,v 1.2 2008/07/22 19:43:28 dtayl Exp $

source harvest.env
JAVA_HARVEST_HOME=/usr
LOAD_FILE=$1

cd $RUN

# looping to build classpath. skipping anything named old.*.jar
#
#
#echo "building classpath"
for file in `ls $HARVEST_HOME/jar/` ; do
 case "$file" in
  old.*.jar)
  ;;
  *.jar|*.zip)
        if [ "$CLASSPATH" != "" ]; then
           CLASSPATH=${CLASSPATH}:$HARVEST_HOME/jar/$file
        else
           CLASSPATH=$HARVEST_HOME/jar/$file
        fi
  ;;
 esac
done

# Weblogic jar file
for file in `ls $HARVEST_HOME/WebLogic_lib/` ; do
 case "$file" in
  old.*.jar)
  ;;
  *.jar|*.zip)
        if [ "$CLASSPATH" != "" ]; then
           CLASSPATH=${CLASSPATH}:$HARVEST_HOME/WebLogic_lib/$file
        else
           CLASSPATH=$HARVEST_HOME/WebLogic_lib/$file
        fi
        ;;
 esac
done
#
# Log4j requires that its property file be specified in the CLASSPATH as
# well as the name of its property file be specified as a command-line argument
# -Dlog4j.configuration=<property file>
#
CLASSPATH=${CLASSPATH}:$CONF_HARVEST_HOME

$JAVA_HARVEST_HOME/bin/java -Djava.security.egd=file:///dev/urandom -Dlog4j.configuration=harvester.properties -Dhttps.protocols=TLSv1.2 -cp $CLASSPATH edu.stanford.harvester.Harvester $CONF_HARVEST_HOME/harvester.properties $CONF_HARVEST_HOME/$PROCESSOR $LOAD_FILE
EXIT_CODE=$?

sed -i '/DOCTYPE Person SYSTEM/d' $HARVEST

HARVEST=$HARVEST $HARVEST_HOME/run/folio-userload.sh

rake illiad:fetch_and_load_users

# Save output files
if [[ -e $HARVEST ]]; then
   mv $HARVEST $OUT $HARVEST.$DATE
else
   mv $OUT/harvest.out $OUT/harvest.out.$DATE
   mv $OUT/harvest.xml.out $OUT/harvest.xml.out.$DATE
fi

# Save and reset log files
mv $LOG/harvest.log $LOG/harvest.log.$DATE

touch $LOG/harvest.log

if [ $EXIT_CODE -gt 0 ] ; then
  echo "Processor exited abnormally. Check log file for details"
  exit $EXIT_CODE
fi
