#! /bin/bash
if [ "${S3ENABLE:-false}" == "true" ] && [[ ! $(s3cmd ls "s3://${S3BUCKET}/config.yml") ]]; then
    s3cmd -q put "${DA_CONFIG_FILE}" "s3://${S3BUCKET}/config.yml"
fi