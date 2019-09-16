#! /bin/bash


if [ "${AZUREENABLE:-false}" == "true" ] && [[ ! $(python -m docassemble.webapp.list-cloud files) ]]; then
    if [ -d "${DA_ROOT}/files" ]; then
        for the_file in $(ls "${DA_ROOT}/files"); do
            if [[ $the_file =~ ^[0-9]+ ]]; then
                for sub_file in $(find "${DA_ROOT}/files/$the_file" -type f); do
                    file_number="${sub_file#${DA_ROOT}/files/}"
                    file_number="${file_number:0:15}"
                    file_directory="${DA_ROOT}/files/$file_number/"
                    target_file="${sub_file#${file_directory}}"
                    file_number="${file_number//\//}"
                    file_number=$((16#$file_number))
                    echo blob-cmd -f cp "${sub_file}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/files/${file_number}/${target_file}"
                done
            else
                for sub_file in $(find "${DA_ROOT}/files/$the_file" -type f); do
                    target_file="${sub_file#${DA_ROOT}/files/}"
                    echo blob-cmd -f cp "${sub_file}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/${target_file}"
                done
            fi
        done
    fi
fi