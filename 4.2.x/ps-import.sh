#!/bin/sh

# **************************************************
# ** Init BASEDIR                                 **
# **************************************************

PHYSICAL_PATH=`readlink -f $0`
BASEDIR=`dirname $PHYSICAL_PATH`
cd $BASEDIR
DIR=`pwd`



# **************************************************
# ** Init JAVA ENVIRONMENT                        **
# **************************************************

. "$DIR/set-pentaho-env.sh"
setPentahoEnv
setClasspath
setJDBC



# **************************************************
# ** Init PROJECT ENVIRONMENT                     **
# **************************************************

. "$DIR/set-project-env.sh"
setProjectEnv $1 $2



# **************************************************
# ** Platform specific libraries ...              **
# **************************************************

# circumvention for the IBM JVM behavior (seems to be a problem with the IBM JVM native compiler)
if [ `uname -s` = "OS400" ]
then
  CLASSPATH=${CLASSPATH}:$BASEDIR/libswt/aix/swt.jar
fi



# ******************************************************************
# ** Set java runtime options                                     **
# ** Change 512m to higher values in case you run out of memory   **
# ** or set the PENTAHO_DI_JAVA_OPTIONS environment variable      **
# ** (JAVAMEMOPTIONS is there for compatibility reasons)          **
# ******************************************************************

if [ -z "$JAVAMEMOPTIONS" ]; then
    JAVAMEMOPTIONS="-Xmx512m"
fi

if [ -z "$PENTAHO_DI_JAVA_OPTIONS" ]; then
    PENTAHO_DI_JAVA_OPTIONS=$JAVAMEMOPTIONS
fi



# ******************************************************************
# ** Set KETTLE_HOME option                                       **
# ** if KETTLE_HOME is empty, then change it to Kettle directory  **
# ******************************************************************

if [ ! $KETTLE_HOME ]; then
	KETTLE_HOME=$DIR
fi



# ******************************************************************
# ** Set STARTUP options                                          **
# ******************************************************************

OPT="$PENTAHO_DI_JAVA_OPTIONS -cp $CLASSPATH -DDI_HOME=$DIR $SHARED_OBJECTS -DKETTLE_HOME=$KETTLE_HOME -DKETTLE_REPOSITORY=$KETTLE_REPOSITORY -DKETTLE_USER=$KETTLE_USER -DKETTLE_PASSWORD=$KETTLE_PASSWORD -DKETTLE_PLUGIN_PACKAGES=$KETTLE_PLUGIN_PACKAGES -DKETTLE_LOG_SIZE_LIMIT=$KETTLE_LOG_SIZE_LIMIT -DPROJECT_HOME=\"$PROJECT_HOME\" -DPROJECT_REPOSITORY=\"$PROJECT_REPOSITORY\""

if [ "$1" = "-x" ]; then
  set LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./libext
  export LD_LIBRARY_PATH
  OPT="-Xruntracer $OPT"
  shift
fi



# ***************
# ** Run...    **
# ***************

"$_PENTAHO_JAVA" $OPT org.pentaho.di.imp.Import "${1+$@}"



cd - > /dev/null
