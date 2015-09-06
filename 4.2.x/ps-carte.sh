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
setLibPath ".." # relative path to lib/kettle-engine.jar
setClasspath
setJDBC



# **************************************************
# ** Init PROJECT ENVIRONMENT                     **
# **************************************************

. "$DIR/set-project-env.sh"
setProjectEnv $1 $2



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
# ** Set STARTUP options                                          **
# ******************************************************************

OPT="$PENTAHO_DI_JAVA_OPTIONS -cp $CLASSPATH -Dorg.mortbay.util.URI.charset=UTF-8 -Djava.library.path=$LIBPATH $SHARED_OBJECTS -DKETTLE_HOME=$KETTLE_HOME -DKETTLE_REPOSITORY=$KETTLE_REPOSITORY -DKETTLE_USER=$KETTLE_USER -DKETTLE_PASSWORD=$KETTLE_PASSWORD -DKETTLE_PLUGIN_PACKAGES=$KETTLE_PLUGIN_PACKAGES -DKETTLE_LOG_SIZE_LIMIT=$KETTLE_LOG_SIZE_LIMIT -DPROJECT_HOME=\"$PROJECT_HOME\" -DPROJECT_REPOSITORY=\"$PROJECT_REPOSITORY\""



# ******************************************************************
# ** Set up the options for JAAS                                  **
# ******************************************************************

if [ ! "x$JAAS_LOGIN_MODULE_CONFIG" = "x" -a ! "x$JAAS_LOGIN_MODULE_NAME" = "x" ]; then
	OPT=$OPT" -Djava.security.auth.login.config=$JAAS_LOGIN_MODULE_CONFIG"
	OPT=$OPT" -Dloginmodulename=$JAAS_LOGIN_MODULE_NAME"
fi

# ***************
# ** Run...    **
# ***************

"$_PENTAHO_JAVA" $OPT org.pentaho.di.www.Carte "${1+$@}"



cd - > /dev/null
