#!/bin/bash

set -e

TARGET=${TARGET:-"hybris"}
PIPELINE_NAME=${PIPELINE_NAME:-"bosh-manifest-generator"}

if ! [ -x "$(command -v spruce)" ]; then
  echo 'spruce is not installed. Please download at https://github.com/geofffranks/spruce/releases' >&2
fi

if ! [ -x "$(command -v fly)" ]; then
  echo 'fly is not installed.' >&2
fi

PIPELINE=$(mktemp /tmp/pipeline.XXXXX)
CREDENTIALS=$(mktemp /tmp/credentials.XXXXX)

spruce --concourse merge \
  stub.yml \
  groups.yml \
  resources.yml \
  jobs/run-test.yml \
  jobs/build-image.yml \
  > ${PIPELINE}

vault read  -field=value -tls-skip-verify secret/bosh/bosh-manifest-generator/concourse > ${CREDENTIALS}

fly -t ${TARGET} set-pipeline -c ${PIPELINE} --load-vars-from=${CREDENTIALS} --pipeline=${PIPELINE_NAME}
if [ $? -ne 0 ]; then
  echo "Please login first: fly -t ${TARGET} login -k"
fi

rm $PIPELINE
rm $CREDENTIALS
