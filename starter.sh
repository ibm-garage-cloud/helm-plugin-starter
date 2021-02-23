#!/bin/bash
# Copyright (c) 2018, salesforce.com, inc.
# All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
# For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

set -e

usage() {
cat << EOF
Fetch, list, and delete helm starters from github.

Available Commands:
    helm starter fetch GITURL [--name NAME]  Install a bare Helm starter from Github (e.g git clone)
    helm starter list                        List installed Helm starters
    helm starter delete NAME                 Delete an installed Helm starter
    --help                                   Display this text
EOF
}

HELM_DATA_HOME=$(helm env HELM_DATA_HOME)

if [[ -z "${HELM_DATA_HOME}" ]]; then
  HELM_DATA_HOME="${HOME}/.helm"
fi

HELM_PATH_STARTER="${HELM_DATA_HOME}/starters"

mkdir -p "${HELM_PATH_STARTER}"

# Create the passthru array
PASSTHRU=()
while [[ $# -gt 0 ]]
do
key="$1"

# Parse arguments
case $key in
    --help)
    HELP=TRUE
    shift # past argument
    ;;
    *)    # unknown option
    PASSTHRU+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

# Restore PASSTHRU parameters
set -- "${PASSTHRU[@]}" 

# Show help if flagged
if [ "$HELP" == "TRUE" ]; then
    usage
    exit 0
fi

# COMMAND must be either 'fetch', 'list', or 'delete'
COMMAND=${PASSTHRU[0]}

if [ "$COMMAND" == "fetch" ]; then
    REPO=${PASSTHRU[1]}
    NAME_ARG=${PASSTHRU[2]}
    NAME_VALUE=${PASSTHRU[3]}
    if [[ -n "${NAME_ARG}" ]]; then
      if [[ "${NAME_ARG}" =~ .*=.* ]]; then
        STARTER_NAME=$(echo "${NAME_ARG}" | sed "s/.*=//g")
      elif [[ -n "${NAME_VALUE}" ]]; then
        STARTER_NAME="${NAME_VALUE}"
      fi
    fi

    cd ${HELM_PATH_STARTER}
    if [[ -n "${STARTER_NAME}" ]]; then
      echo "Fetching ${REPO} into ${HELM_PATH_STARTER}/${STARTER_NAME}"
      git clone ${REPO} ${STARTER_NAME} --quiet
    else
      echo "Fetching ${REPO} into ${HELM_PATH_STARTER}"
      git clone ${REPO} --quiet
    fi
    cd $OLDPWD
    exit 0
elif [ "$COMMAND" == "list" ]; then
    ls -A1 ${HELM_PATH_STARTER}
    exit 0
elif [ "$COMMAND" == "delete" ]; then 
    STARTER=${PASSTHRU[1]}
    rm -rf ${HELM_PATH_STARTER}/${STARTER}
    exit 0
else
    echo "Error: Invalid command, must be one of 'fetch', 'list', or 'delete'"
    usage
    exit 1
fi
