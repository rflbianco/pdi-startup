#!/bin/sh

DEFAULT_VERSION="4.2.x"
DEFAULT_BRANCH="master"
DEFAULT_INSTALLATION="./"

usage() {
    echo "Usage: $0 [--branch BRANCH_NAME] [--version PDI_VERSION] [--installation PATH]"
    echo ""
    echo "Options:"
    echo "    --help                    Shows this usage and exits."
    echo ""
    echo "    --branch BRANCH_NAME      Allows selecting which branch of git repoository to install from. Default: ${DEFAULT_BRANCH}"
    echo "    --version PDI_VERSION     Which PDI version / series must be installed. Default: latest supported version (${DEFAULT_VERSION})"
    echo "    --installation PATH       PDI installation path. Default: ${DEFAULT_INSTALLATION}"
}

while [ -n "$1" ]; do
    case $1 in
        '--version')
            _version="$2"
            if [ -z "$_version" ]; then
                echo "Bad usage. Param '--version' requires a value. See usage."
                usage
                exit 1
            fi
            shift
            ;;
        '--branch')
            _branch="$2"
            if [ -z "$_branch" ]; then
                echo "Bad usage. Param '--branch' requires a value. See usage."
                usage
                exit 1
            fi
            shift
            ;;
        '--installation')
            _installation="$2"
            if [ -z "$_installation" ]; then
                echo "Bad usage. Param '--installation' requires a value. See usage."
                usage
                exit 1
            fi
            if [ ! -d "$_installation" ]; then
                echo "Bad usage. Invalid param value. Param '--installation' requires a valid path: '${_installation}' does not exists or is not a folder."
                usage
                exit 1
            fi
            shift
            ;;
        '--help')
            usage
            exit
            ;;
        *)
            ;;
    esac
    shift
done


version=${_version:-$DEFAULT_VERSION}
branch=${_branch:-$DEFAULT_BRANCH}
installation=${_installation:-$DEFAULT_INSTALLATION}

url="https://github.com/instituto-stela/pdi-startup/archive/${branch}.zip"
tmp_file="/tmp/pdi-startup-${version}.zip"
tmp_folder="/tmp/pdi-startup-${version}"

echo "#########################################################################"
echo "Installing PDI Startup scripts for version '${version}' into '$(readlink -f ${installation})' from branch '${branch}'..."
echo ""

wget $url -O "${tmp_file}"
if [ $? -gt 0 ]; then
    echo "Error while downloading PDI Startup scripts. Probable cause: branch '${branch}' does not exists. See 'stdout' for more information."
    exit 1
fi

unzip -o "${tmp_file}" -d "${tmp_folder}"
if [ $? -gt 0 ]; then
    echo "Error while extracting PDI Startup scripts. Probable cause: permission on unzip output folder '${tmp_folder}'. See 'stdout' for more information."
    exit 1
fi

cp -R ${tmp_folder}/pdi-startup-${branch}/${version}/* ${installation}
if [ $? -gt 0 ]; then
    echo "Error while installing PDI Startup scripts. Probable cause: version '${version}' is not supported in branch '${branch}'. See 'stdout' for more information."
    exit 1
fi

echo "PDI Startup scripts installed successfully"