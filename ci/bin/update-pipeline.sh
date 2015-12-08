#!/bin/bash

set -e

TARGET=${TARGET:-"sap"}
PIPELINE_NAME=${PIPELINE_NAME:-"bosh-manifest-generator"}
CREDENTIALS=${CREDENTIALS:-"credentials.yml"}

if ! [ -x "$(command -v spruce)" ]; then
  echo 'spruce is not installed. Please download at https://github.com/geofffranks/spruce/releases' >&2
fi

if ! [ -x "$(command -v fly)" ]; then
  echo 'fly is not installed.' >&2
fi

PIPELINE=$(mktemp /tmp/pipeline.XXXXX)

spruce --concourse merge \
  stub.yml \
  groups.yml \
  resources.yml \
  jobs/run-test.yml \
  jobs/build-image.yml \
  > ${PIPELINE}

fly -t ${TARGET} set-pipeline -c ${PIPELINE} -l ${CREDENTIALS} -p ${PIPELINE_NAME} -n
