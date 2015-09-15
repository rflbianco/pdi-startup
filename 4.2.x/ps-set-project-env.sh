#!/bin/bash

setProjectEnv() {
	declare -a __CUSTOM_ENV

	while [ "$1" ]; do
		case "$1" in
			"--project")
				if [ -z "$2" -o ! -d "$2" ]; then
					echo "Bad usage: parameter '--project' needs a existing directory as value."
					exit 1
				fi
				PROJECT_HOME="$2"
				shift
				;;
			"--env")
				if [ -z "$2" ]; then
					echo "Bad usage: parameter '--env' needs a value"
					exit 1
				fi
				ENV_SUFFIX="$2"
				shift
				;;
			-D*)
				__CUSTOM_ENV+=("$1")
				;;
			*)
				;;
		esac
		shift
	done

	if [ -n "$PROJECT_HOME" ]; then
		PROJECT_REPOSITORY="${PROJECT_HOME}/repository"

		if [ -n "$ENV_SUFFIX" ]; then
			KETTLE_SHARED_OBJECT="${PROJECT_REPOSITORY}/shared-${ENV_SUFFIX}.xml"
		else
			KETTLE_SHARED_OBJECT="${PROJECT_REPOSITORY}/shared.xml"
		fi
	fi

	if [ ${#__CUSTOM_ENV[@]} -gt 0 ]; then
		echo "exporting CUSTOM_ENV"
		CUSTOM_ENV="${__CUSTOM_ENV[@]}"
	fi

	echo "PROJECT_HOME = $PROJECT_HOME"
	echo "PROJECT_REPOSITORY = $PROJECT_REPOSITORY"
	echo "KETTLE_SHARED_OBJECT = $KETTLE_SHARED_OBJECT"
	echo "CUSTOM_ENV = ${CUSTOM_ENV}"
}
