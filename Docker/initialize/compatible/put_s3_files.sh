#! /bin/bash

if [ "${S3ENABLE:-false}" == "true" ] && [[ ! $(s3cmd ls "s3://${S3BUCKET}/files") ]]; then
    if [ -d "${DA_ROOT}/files" ]; then
        for the_file in $(ls "${DA_ROOT}/files"); do
            if [[ $the_file =~ ^[0-9]+ ]]; then
                for sub_file in $(find "${DA_ROOT}/files/$the_file" -type f); do
                    file_number="${sub_file#${DA_ROOT}/files/}"
                    file_number="${file_number:0:15}"
                    file_directory="${DA_ROOT}/files/$file_number"
                    target_file="${sub_file#${file_directory}}"
                    file_number="${file_number//\//}"
                    file_number=$((16#$file_number))
                    s3cmd -q put "${sub_file}" "s3://${S3BUCKET}/files/${file_number}/${target_file}"
                done
            else
               s3cmd -q sync "${DA_ROOT}/files/${the_file}/" "s3://${S3BUCKET}/${the_file}/"
            fi
        done
    fi
fi