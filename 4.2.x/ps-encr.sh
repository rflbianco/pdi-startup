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



# ******************************************************************
# ** Set STARTUP options                                          **
# ******************************************************************

OPT="-cp $CLASSPATH"



# ***************
# ** Run...    **
# ***************

"$_PENTAHO_JAVA" $OPT org.pentaho.di.core.encryption.Encr "${1+$@}"



cd - > /dev/null
