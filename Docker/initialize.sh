#! /bin/bash

N=`date +%s%N`
export PS4='+[$(((`date +%s%N`-$N)/1000000))ms][${BASH_SOURCE}:${LINENO}]: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'; set -x;

export HOME=/root
export DA_ROOT="${DA_ROOT:-/usr/share/docassemble}"
export DA_INITIALIZE="${DA_ROOT}/initialize"
export DAPYTHONVERSION="${DAPYTHONVERSION:-2}"
export ENV_TYPE="debian"
export DA_USER="docassemble"
export DA_GROUP="docassemble"

if [ "${DAPYTHONVERSION}" == "2" ]; then
    export DA_DEFAULT_LOCAL="local"
else
    export DA_DEFAULT_LOCAL="local3.5"
fi

export DA_ACTIVATE="${DA_PYTHON:-${DA_ROOT}/${DA_DEFAULT_LOCAL}}/bin/activate"
echo "Activating with ${DA_ACTIVATE}" >&2
source "${DA_ACTIVATE}"

export DA_CONFIG_FILE_DIST="${DA_CONFIG_FILE_DIST:-${DA_ROOT}/config/config.yml.dist}"
export DA_CONFIG_FILE="${DA_CONFIG:-${DA_ROOT}/config/config.yml}"
export CONTAINERROLE=":${CONTAINERROLE:-all}:"

echo "ContainerRole is '$CONTAINERROLE'" >&2
echo "config.yml is at " $DA_CONFIG_FILE >&2

echo "1a : Clean Apt" >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/clean_repo.sh"

echo "1b : Install S3CMD " >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/install_s3cmd.sh"

echo "1c : Install Pandoc " >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/install_pandoc.sh"

echo "2 : Is Apache Running" >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/determine_apache_running.sh"

echo "3 : Is Redis Running" >&2
source "${DA_INITIALIZE}/compatible/determine_redis_running.sh"

echo "4 : Is Cron Running" >&2
source "${DA_INITIALIZE}/compatible/determine_cron_running.sh"

echo "5 : Determine Url Root" >&2
source "${DA_INITIALIZE}/compatible/determine_url_root.sh"

echo "6 : Determine Host Name" >&2
source "${DA_INITIALIZE}/compatible/determine_hostname.sh"

echo "7 : Determine S3 Details" >&2
source "${DA_INITIALIZE}/compatible/determine_s3_enabled.sh"

echo "8 : Set S3 Details" >&2
source "${DA_INITIALIZE}/compatible/set_s3_details.sh"

echo "9 : Determine Azure enabled" >&2
source "${DA_INITIALIZE}/compatible/determine_azure_enabled.sh"

echo "10 : Determine RabbitMQ from Azure" >&2
source "${DA_INITIALIZE}/compatible/determine_rabbitmq_from_azure.sh"

echo "11 : Initialize Azure" >&2
source "${DA_INITIALIZE}/compatible/initialize_azure.sh"

echo "12 : Determine RabbitMQ from s3" >&2
source "${DA_INITIALIZE}/compatible/determine_rabbitmq_from_s3.sh"

echo "13 : Configure from S3" >&2
source "${DA_INITIALIZE}/compatible/configure_from_s3.sh"

echo "14 : Set default secret" >&2
source "${DA_INITIALIZE}/compatible/set_default_secret.sh"

echo "15 : Set default configuration" >&2
source "${DA_INITIALIZE}/compatible/set_default_configuration.sh"

echo "16 : Set Log Directory" >&2
source "${DA_INITIALIZE}/compatible/set_log_directory.sh"

echo "17 : Put S3 Config File" >&2
source "${DA_INITIALIZE}/compatible/put_s3_config_file.sh"

echo "17A : Put S3 Files" >&2
source "${DA_INITIALIZE}/compatible/put_s3_files.sh"

echo "18 : Add Azure Account" >&2
source "${DA_INITIALIZE}/compatible/add_azure_account.sh"

echo "19 : Put Azure config file" >&2
source "${DA_INITIALIZE}/compatible/put_azure_config_file.sh"

echo "19.5 : Put Azure Files" >&2
source "${DA_INITIALIZE}/compatible/put_azure_files.sh"

echo "20: Export hostname" >&2
source "${DA_INITIALIZE}/compatible/export_hostname.sh"

echo "21 : Set the default da hostname " >&2
source "${DA_INITIALIZE}/compatible/set_default_da_hostname.sh"

echo "22 : Clear Lets Encrypt and copy apache configuration" >&2
source "${DA_INITIALIZE}/compatible/apache/copy_configuration.sh"

echo "23 : Set Default Locale" >&2
source "${DA_INITIALIZE}/compatible/set_default_locale.sh"

echo "24 : Export Locale" >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/export_locale.sh"

echo "25 : Install other locales" >&2
source "${DA_INITIALIZE}/compatible/other_locales.sh"

echo "26 : Install Apt Packages" >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/install_additional_packages.sh"

echo "26.5 : Install Additional Python Packages" >&2
source "${DA_INITIALIZE}/compatible/install_additional_python_packages.sh"

echo "27 : Configure Timezone" >&2
source "${DA_INITIALIZE}/${ENV_TYPE}/configure_timezone.sh"

echo "28 : Cloud Register" >&2
source "${DA_INITIALIZE}/compatible/cloud_register.sh"

echo "29 : Checking if postgres is running" >&2
source "${DA_INITIALIZE}/compatible/check_postgres_up.sh"

echo "29 : Configure Postgres" >&2
source "${DA_INITIALIZE}/compatible/postgres/configure.sh"

echo "30 : Create or Fix SQL Tables" >&2
source "${DA_INITIALIZE}/compatible/sql/create_or_fix_sql_tables.sh"

echo "30b : Run additional SQL files "
source "${DA_INITIALIZE}/compatible/sql/run_additional_sql_files.sh"

echo "31 : Copy Syslog Configuration" >&2
source "${DA_INITIALIZE}/compatible/syslog/copy_configuration.sh"

echo "32 : Check whether the other log server is set" >&2
source "${DA_INITIALIZE}/compatible/otherlogserver/check_state.sh"

echo "33 :  Check whether the other log server should be disabled" >&2
source "${DA_INITIALIZE}/compatible/otherlogserver/disable_if_required.sh"

echo "34 : Set the permissions for the other log server" >&2
source "${DA_INITIALIZE}/compatible/otherlogserver/configure_permissions.sh"

echo "35 : No-operation" >&2

echo "36 : Start Redis" >&2
source "${DA_INITIALIZE}/compatible/redis/start.sh"

echo "37A : Upgrade Packages" >&2
source "${DA_INITIALIZE}/compatible/upgrade_packages.sh"

echo "37B : Upgrade Python Packages " >&2
source "${DA_INITIALIZE}/compatible/upgrade_initial_packages.sh"

echo "38B  : Start Rabbit if required" >&2
source "${DA_INITIALIZE}/compatible/rabbit/start.sh"

if [[ $CONTAINERROLE =~ .*:(all|lr|celery):.* ]]; then 
    echo "39 : Check celery is running" >&2
    source "${DA_INITIALIZE}/compatible/celery/determine_running.sh"

    echo "40 : Start Celery" >&2
    source "${DA_INITIALIZE}/compatible/celery/start.sh"
fi

echo "41 : Delete Port Configuration" >&2
source "${DA_INITIALIZE}/compatible/apache/delete_port_configuration.sh"

echo "42A : Copy apache certificates into place" >&2
source "${DA_INITIALIZE}/compatible/apache/copy_configuration.sh"

echo "42B : Copy exim certificates into place" >&2
source "${DA_INITIALIZE}/compatible/exim/copy_configuration.sh"

echo "42C : Copy exim certificates into place" >&2
source "${DA_INITIALIZE}/compatible/install_certificates.sh"

function backup_apache {
    source "${DA_INITIALIZE}/compatible/apache/backup.sh"
}

echo "43 : Configure Apache" >&2
source "${DA_INITIALIZE}/compatible/apache/configure_apache.sh"

echo "44 : Enable Logging Apache Site" >&2
source "${DA_INITIALIZE}/compatible/apache/enable_logging_site.sh"

echo "45 : Start Websockets" >&2
source "${DA_INITIALIZE}/compatible/websockets/start.sh"

echo "46 : Start Apache" >&2
source "${DA_INITIALIZE}/compatible/apache/start.sh"

echo "47 : Configure HTTPS" >&2
source "${DA_INITIALIZE}/compatible/apache/configure_https_and_restart.sh"

echo "48 : Register Docassemble Application" >&2
source "${DA_INITIALIZE}/register_docassemble.sh"

echo "49 : Start Cron" >&2
source "${DA_INITIALIZE}/compatible/cron/start.sh"

echo "50 : Configure Mail Server" >&2
source "${DA_INITIALIZE}/compatible/exim/configure_mailserver.sh"

echo "51 : Start Syslog" >&2
source "${DA_INITIALIZE}/compatible/syslog/start.sh"

function deregister {

    source "${DA_INITIALIZE}/compatible/deregister.sh"
    kill %1
    exit 0
}

trap deregister SIGINT SIGTERM
echo "initialize finished" >&2
sleep infinity &
wait %1
