#!/usr/bin/env bash
set -eo pipefail

usage()
{
  echo -e "============================Usage================================\n"
  echo -e "$0 [ -h|-i|-c|-a ] [ -d DB_DUMP ]"
  echo -e "$0 -h: print the usage ..."
  echo -e "$0 -c: clean the db ..."
  echo -e "$0 -a -d DB_DUMP_FILE_PATH: import the db and clean settings ..."
  echo -e "$0 -i -d DB_DUMP_FILE_PATH: import the db ..."
  echo -e "============================Usage================================\n"
}

echo "== Get the Mysql password instantly before running ..."
config_file="/var/www/errata_rails/config/database.yml"
echo "grep password ${config_file} |  cut -d : -f 2 | tr -d ' '"
MYSQL_PASSWORD=$(grep password ${config_file} |  cut -d : -f 2 | tr -d ' ')
export MYSQL_PASSWORD=${MYSQL_PASSWORD}
echo "== Have exported the MYSQL_PASSWORD as enviromental variables ..."

set_variable()
{
  # Declare one local variable
  local varname=$1
  # Move on
  shift
  # If the varname has not been set, set the $varname=$1
  # The exclamation mark before varname tells the shell to replace
  # that with the value of $varname
  # ACTION=SAVE
  if [ -z "${!varname}" ]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}


import_database()
{
  echo "== I am importing db dump ${1} to errata database ..."
  echo gunzip < $1 | mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata
  gunzip < $1 | mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata
}


clean_db_settings()
{
  echo "== I am cleaning the setting tables of the errata db ..."
  echo mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata -e "delete from settings where id>0;"
  mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata -e "delete from settings where id>0;"
  echo "== I am checking the clean result ..."
  echo mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata -e "select * from settings;"
  result=$(mysql -uerrata -p"${MYSQL_PASSWORD}" -Derrata -e "select * from settings;")
  if [ -z ${result} ]; then
    echo "== Empty! Clean Done! Cheers =="
  else
    echo "== Failed ... The settings still have data ..."
  fi
}

while getopts 'hicd:' c
do
  case $c in
    h) usage ;;
    i) set_variable ACTION IMPORT ;;
    c) set_variable ACTION CLEAN ;;
    a) set_variable ACTION IMPORT_AND_CLEAN ;;
    d) set_variable DB_DUMP $OPTARG ;;
  esac
done

if [ -n "${DB_DUMP}" ]; then
  case $ACTION in
    IMPORT) import_database ${DB_DUMP}  ;;
    IMPORT_AND_CLEAN) import_database ${DB_DUMP} && clean_db_settings ;;
  esac
else
  case $ACTION in
    CLEAN) clean_db_settings;;
  esac
fi


