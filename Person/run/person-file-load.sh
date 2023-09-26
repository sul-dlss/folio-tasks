#!/bin/sh

source $(dirname $0)/harvest.env
JAVA_HARVEST_HOME=/usr

cd $RUN

HARNESS_LOG=$HARVEST_HOME/log/harness.log

if [ ! -f $HARNESS_LOG ]
then
    touch $HARNESS_LOG
fi

dfmt='+%m/%d/%Y %H:%M'
t_stamp=`date "$dfmt"`

printf "\n$t_stamp $APP_NAME $0 harness starts\n"
printf "\n\n$t_stamp $APP_NAME $0 harness starts\n" >> $HARNESS_LOG

# looping to build classpath. skipping anything named old.*.jar
#
# Support jar files
echo "$t_stamp harness building classpath" >> $HARNESS_LOG
for file in `ls $HARVEST_HOME/jar/` ; do
 case "$file" in
  old.*.jar) echo skipping $file >>$HARNESS_LOG;;
  *.jar|*.zip) echo ADDING $file >> $HARNESS_LOG
        if [ "$CLASSPATH" != "" ]; then
           CLASSPATH=${CLASSPATH}:$HARVEST_HOME/jar/$file
        else
           CLASSPATH=$HARVEST_HOME/jar/$file
        fi
        ;;
 esac
done
#
# Weblogic jar file
for file in `ls $HARVEST_HOME/WebLogic_lib/` ; do
 case "$file" in
  old.*.jar) echo skipping $file >>$HARNESS_LOG;;
  *.jar|*.zip) echo ADDING $file >> $HARNESS_LOG
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


$JAVA_HOME/bin/java -Dweblogic.StdoutSeverityLevel=16 -Dweblogic.security.SSL.ignoreHostnameVerification=true -Djava.security.egd=file:///dev/urandom -Dlog4j.configuration=harvester.properties -Dhttps.protocols=TLSv1.2 -cp $CLASSPATH edu.stanford.harvester.Harvester $CONF_HARVEST_HOME/harvester.properties $CONF_HARVEST_HOME/processor.properties $1 >> $HARNESS_LOG 2>&1

EXIT_CODE=$?

t_stamp=`date "$dfmt"`
echo "$t_stamp $APP_NAME exit to harness, exit status $EXIT_CODE" >> $HARNESS_LOG
