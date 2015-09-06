#!/bin/sh


# **************************************************
# ** Set these to the location of your mozilla
# ** installation directory.  Use a Mozilla with
# ** Gtk2 and Fte enabled.
# **************************************************

# set MOZILLA_FIVE_HOME=/usr/local/mozilla
# set LD_LIBRARY_PATH=/usr/local/mozilla

# Try to guess xulrunner location - change this if you need to
MOZILLA_FIVE_HOME=$(find /usr/lib -maxdepth 1 -name xulrunner-[0-9]* | head -1)
LD_LIBRARY_PATH=${MOZILLA_FIVE_HOME}:${LD_LIBRARY_PATH}
export MOZILLA_FIVE_HOME LD_LIBRARY_PATH

# Fix for GTK Windows issues with SWT
export GDK_NATIVE_WINDOWS=1

# Fix overlay scrollbar bug with Ubuntu 11.04
export LIBOVERLAY_SCROLLBAR=0


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


. "$DIR/ps-set-pentaho-env.sh"
setPentahoEnv
setLibPath ".." # relative path to launcher/launcher.jar



# **************************************************
# ** Init PROJECT ENVIRONMENT                     **
# **************************************************

. "$DIR/ps-set-project-env.sh"
setProjectEnv "$@"



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

# OPT=""$PENTAHO_DI_JAVA_OPTIONS" -Djava.library.path="$LIBPATH" "$SHARED_OBJECTS" -DKETTLE_HOME="$KETTLE_HOME" -DKETTLE_REPOSITORY="$KETTLE_REPOSITORY" -DKETTLE_USER="$KETTLE_USER" -DKETTLE_PASSWORD="$KETTLE_PASSWORD" -DKETTLE_PLUGIN_PACKAGES="$KETTLE_PLUGIN_PACKAGES" -DKETTLE_LOG_SIZE_LIMIT="$KETTLE_LOG_SIZE_LIMIT" -DPROJECT_HOME="$PROJECT_HOME" -DPROJECT_REPOSITORY="$PROJECT_REPOSITORY""


# ***************
# ** Run...    **
# ***************

STARTUP="$DIR/launcher/launcher.jar"


"$_PENTAHO_JAVA" $PENTAHO_DI_JAVA_OPTIONS -Djava.library.path="$LIBPATH" -DKETTLE_SHARED_OBJECTS="$KETTLE_SHARED_OBJECT" -DKETTLE_HOME="$KETTLE_HOME" -DKETTLE_REPOSITORY=$KETTLE_REPOSITORY -DKETTLE_USER=$KETTLE_USER -DKETTLE_PASSWORD=$KETTLE_PASSWORD -DKETTLE_PLUGIN_PACKAGES=$KETTLE_PLUGIN_PACKAGES -DKETTLE_LOG_SIZE_LIMIT=$KETTLE_LOG_SIZE_LIMIT -DPROJECT_HOME="$PROJECT_HOME" -DPROJECT_REPOSITORY="$PROJECT_REPOSITORY" -jar "$STARTUP" -lib "$LIBPATH" "$@"
