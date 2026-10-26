#!/bin/bash

show_help() {
cat << EOF
Update packages on a pfsense host for emergency security issues.
Usage: ${0##*/} --k PRIVATE_KEY -s hostname [-p port] [-u username] [-v]
Options:
    -h|--help: Print this help and exit
    -s|--hostname: Hostname or IP of the pfsense box. (required)
    -k|--keyfile: Path to a file containing the private key in PEM format (required)
    -p|--port: Port to use for SSH connection (default: 22)
    -u|--username: Username to use for login (default: admin)
    -z|--zabbixversion: Unused parameter
    -v|--verbose: Print debug information
EOF
}

HOST=""
KEY=""
PORT=22
USER=admin
VERBOSE=0
VER=7

# Command line interface
TEMP=`getopt -o hvk:p:s:u:z: --long help,verbose,keyfile:,port:,hostname:,username:,zabbixversion:, \
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
    -s | --hostname ) HOST="$2"; shift 2 ;;
    -u | --username ) USER="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echoerr() { printf "\033[0;31m%s\n\033[0m" "$*" >&2; }
SCRIPT_DIR=$(dirname "$0")
if (( $VERBOSE == 1 )); then echo "Upgrade pfsense..."; fi
if (( $VERBOSE == 1 )); then echo "Copy the update script"; fi
scp -i "$KEY" -P "$PORT" "$SCRIPT_DIR/update_binary_restart.csh" $USER@$HOST:~/update_binary_restart.csh
if [ $? -ne 0 ]; then
    # Can't connect 
    echoerr "Can't connect to $HOST"
    echo 1
    exit
fi 
if (( $VERBOSE == 1 )); then echo "Chmod the script"; fi
ssh -n -T -i "$KEY" -P "$PORT" "$USER@$HOST" 'chmod +x ~/update_binary_restart.csh'
if (( $VERBOSE == 1 )); then echo "Run update script"; fi
ssh -n -T -i "$KEY" -P "$PORT" "$USER@$HOST" 'csh ~/update_binary_restart.csh'

echo 0;