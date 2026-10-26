#!/bin/bash 

show_help() {
cat << EOF
Backup pfsense configuration
Usage: ${0##*/} --k PRIVATE_KEY -s hostname [-p port] [-u username] [-v]
Options:
    -h|--help: Print this help and exit
    -s|--hostname: Hostname or IP of the pfsense box. (required)
    -k|--keyfile: Path to a file containing the private key in PEM format (required)
    -p|--port: Port to use for SSH connection (default: 22)
    -u|--username: Username to use for login (default: admin)
    -f|--pfname: Name of the pfSense box
    -v|--verbose: Print debug information
EOF
}

HOST=""
KEY=""
PORT=22
USER=admin
VERBOSE=0
PFNAME=pf1.acme.com

# Command line interface
TEMP=`getopt -o hvk:p:s:u:f: --long help,verbose,keyfile:,port:,hostname:,username:,pfname:, \
             -n '${0##*/}' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"
while true; do
  case "$1" in
    -h | --help )
        show_help >&2
        exit 1
        shift
        ;;
    -v | --verbose) VERBOSE=1; shift 1 ;;
    -z | --zabbixversion) VER="$2"; shift 2 ;;
    -k | --keyfile ) KEY="$2"; shift 2 ;;
    -p | --port ) PORT="$2"; shift 2 ;;
    -f | --pfname ) PFNAME="$2"; shift 2 ;;
    -s | --hostname ) HOST="$2"; shift 2 ;;
    -u | --username ) USER="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
# Backup PfSense config
echoerr() { printf "\033[0;31m%s\n\033[0m" "$*" >&2; }
SCRIPT_DIR=$(dirname "$0")
DT=$(date '+%Y_%m_%d_%H_%M')
mkdir -p $SCRIPT_DIR/config_backup
mkdir -p $SCRIPT_DIR/config_backup/$PFNAME
# Download /conf/config.xml 
scp -i $KEY -P $PORT  $USER@$HOST:/cf/conf/config.xml $SCRIPT_DIR/config_backup/$PFNAME/config_$DT.xml
if [ $? -ne 0 ]; then
    # Can't connect 
    echoerr "Can't transfer config file from $HOST"
    echo 1
    exit 
fi 
echo 0
