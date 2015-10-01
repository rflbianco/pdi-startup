#!/bin/sh
# -----------------------------------------------------------------------------
# Finds a suitable Java
#
# Looks in well-known locations to find a suitable Java then sets two 
# environment variables for use in other script files. The two environment
# variables are:
# 
# * _PENTAHO_JAVA_HOME - absolute path to Java home
# * _PENTAHO_JAVA - absolute path to Java launcher (e.g. java)
# 
# The order of the search is as follows:
#
# 1. argument #1 - path to Java home
# 2. environment variable PENTAHO_JAVA_HOME - path to Java home
# 3. jre folder at current folder level
# 4. java folder at current folder level
# 5. jre folder one level up
# 6 java folder one level up
# 7. jre folder two levels up
# 8. java folder two levels up
# 9. environment variable JAVA_HOME - path to Java home
# 10. environment variable JRE_HOME - path to Java home


# 
# If a suitable Java is found at one of these locations, then 
# _PENTAHO_JAVA_HOME is set to that location and _PENTAHO_JAVA is set to the 
# absolute path of the Java launcher at that location. If none of these 
# locations are suitable, then _PENTAHO_JAVA_HOME is set to empty string and 
# _PENTAHO_JAVA is set to java.
# 
# Finally, there is one final optional environment variable: PENTAHO_JAVA.
# If set, this value is used in the construction of _PENTAHO_JAVA. If not 
# set, then the value java is used. 
# -----------------------------------------------------------------------------

setPentahoEnv() {
	DIR=`pwd`

	if [ -n "$PENTAHO_JAVA" ]; then
		__LAUNCHER="$PENTAHO_JAVA"
	else
		__LAUNCHER="java"
	fi
	if [ -n "$1" ] && [ -d "$1" ] && [ -x "$1"/bin/$__LAUNCHER ]; then
		# echo "DEBUG: Using value ($1) from calling script"
		_PENTAHO_JAVA_HOME="$1"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER  
	elif [ -n "$PENTAHO_JAVA_HOME" ]; then
		# echo "DEBUG: Using PENTAHO_JAVA_HOME"
		_PENTAHO_JAVA_HOME="$PENTAHO_JAVA_HOME"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/jre/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JRE at the current folder
		_PENTAHO_JAVA_HOME="$DIR/jre"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/java/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JAVA at the current folder
		_PENTAHO_JAVA_HOME="$DIR/java"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/../jre/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JRE one folder up
		_PENTAHO_JAVA_HOME="$DIR/../jre"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/../java/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JAVA one folder up
		_PENTAHO_JAVA_HOME="$DIR/../java"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/../../jre/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JRE two folders up
		_PENTAHO_JAVA_HOME="$DIR/../../jre"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -x "$DIR/../../java/bin/$__LAUNCHER" ]; then
		# echo DEBUG: Found JAVA two folders up
		_PENTAHO_JAVA_HOME="$DIR/../../java"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -n "$JAVA_HOME" ]; then
		# echo "DEBUG: Using JAVA_HOME"
		_PENTAHO_JAVA_HOME="$JAVA_HOME"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	elif [ -n "$JRE_HOME" ]; then
		# echo "DEBUG: Using JRE_HOME"
		_PENTAHO_JAVA_HOME="$JRE_HOME"
		_PENTAHO_JAVA="$_PENTAHO_JAVA_HOME"/bin/$__LAUNCHER
	else
		# echo "WARNING: Using java from path"
		_PENTAHO_JAVA_HOME=
		_PENTAHO_JAVA=$__LAUNCHER
	fi
	# echo "DEBUG: _PENTAHO_JAVA_HOME=$_PENTAHO_JAVA_HOME"
	# echo "DEBUG: _PENTAHO_JAVA=$_PENTAHO_JAVA"
}





# **************************************************
# ** Platform specific libraries ...              **
# **************************************************

setLibPath() {
	BASEDIR=$1
	if [ -z "$BASEDIR" ]; then # avoiding empty parameter BASEDIR
		BASEDIR="."
	fi
	
	LIBPATH="NONE"

	case `uname -s` in 
		AIX)
			LIBPATH=$BASEDIR/libswt/aix/
			;;

		SunOS) 
			LIBPATH=$BASEDIR/libswt/solaris/
			;;

		Darwin)
			echo "Starting Data Integration using 'Spoon.sh' from OS X is not supported."
			echo "Please start using 'Data Integration 32-bit' or"
			echo "'Data Integration 64-bit' as appropriate."
			exit
			;;

		Linux)
			ARCH=`uname -m`
			case $ARCH in
				x86_64)
					if $($_PENTAHO_JAVA -version 2>&1 | grep "64-Bit" > /dev/null )
									then
					  LIBPATH=$BASEDIR/libswt/linux/x86_64/
									else
					  LIBPATH=$BASEDIR/libswt/linux/x86/
									fi
					;;

				i[3-6]86)
					LIBPATH=$BASEDIR/libswt/linux/x86/
					;;

				ppc)
					LIBPATH=$BASEDIR/libswt/linux/ppc/
					;;

				*)	
					echo "I'm sorry, this Linux platform [$ARCH] is not yet supported!"
					exit
					;;
			esac
			;;

		FreeBSD)
			ARCH=`uname -m`
			case $ARCH in
				x86_64)
					LIBPATH=$BASEDIR/libswt/freebsd/x86_64/
					echo "I'm sorry, this Linux platform [$ARCH] is not yet supported!"
					exit
					;;

				i[3-6]86)
					LIBPATH=$BASEDIR/libswt/freebsd/x86/
					;;

				ppc)
					LIBPATH=$BASEDIR/libswt/freebsd/ppc/
					echo "I'm sorry, this FreeBSD platform [$ARCH] is not yet supported!"
					exit
					;;

				*)	
					echo "I'm sorry, this FreeBSD platform [$ARCH] is not yet supported!"
					exit
					;;
			esac
			;;

		HP-UX) 
			LIBPATH=$BASEDIR/libswt/hpux/
			;;
		CYGWIN*)
			./Spoon.bat
			exit
			;;

		*) 
			echo Spoon is not supported on this hosttype : `uname -s`
			exit
			;;
	esac 
}





# **************************************************
# ** Libraries used by Kettle:                    **
# **************************************************

setClasspath() {
	BASEDIR=$1
	# avoiding empty parameter BASEDIR
	if [ -z "$BASEDIR" ]; then
		BASEDIR="."
	fi
	
	# avoiding existing classpath
	if [ ! $CLASSPATH ]; then
		CLASSPATH=$BASEDIR/
	else
		CLASSPATH=$CLASSPATH:$BASEDIR/
	fi
		
	CLASSPATH=$CLASSPATH:$BASEDIR/lib/kettle-core.jar
	CLASSPATH=$CLASSPATH:$BASEDIR/lib/kettle-db.jar
	CLASSPATH=$CLASSPATH:$BASEDIR/lib/kettle-engine.jar
}





# **************************************************
# ** JDBC & other libraries used by Kettle:       **
# **************************************************

setJDBC() {
	BASEDIR=$1
	# avoiding empty parameter BASEDIR
	if [ -z "$BASEDIR" ]; then
		BASEDIR="."
	fi
	
	# avoiding empty classpath
	if [ ! $CLASSPATH ]; then
		CLASSPATH=$BASEDIR/
	fi
		
	for f in `find $BASEDIR/libext -type f -name "*.jar"` `find $BASEDIR/libext -type f -name "*.zip"`
	do
	  CLASSPATH=$CLASSPATH:$f
	done
}
