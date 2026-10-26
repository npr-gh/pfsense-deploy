#!/bin/bash 

show_help() {
cat << EOF
Download backup config for all firewalls. 
To write to log: add '| tee log.file' to the command.
Usage: ${0##*/} --k PRIVATE_KEY -f firewalls.csv
Options:
    -h|--help: Print this help and exit
    -f|--csvfile: File with CSV values for connection
    -k|--keyfile: Path to a file containing the private key in PEM format (required)
    -v|--verbose: debug info.
EOF
}

FILE=""
KEY=""
VERBOSE=0
SCRIPT=deploy.sh

# Command line interface
TEMP=`getopt -o hvf:k:s: --long help,verbose,csvfile:,keyfile:,scriptfile:, \
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
    -f | --csvfile ) FILE="$2"; shift 2 ;;
    -k | --keyfile ) KEY="$2"; shift 2 ;;
    -v | --verbose) VERBOSE=1; shift 1 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
echoerr() { printf "\033[0;31m%s\n\033[0m" "$*" >&2; }
SCRIPT_DIR=$(dirname "$0")
while IFS=',' read -r PFNAME HOSTNAME PORT VER
do
    echo "Downloading ${PFNAME} @ ${HOSTNAME}..."; 
    if (( $VERBOSE == 1 )); then  
        $SCRIPT_DIR/backup_config.sh -v -k $KEY -p $PORT -u admin -s $HOSTNAME -f $PFNAME
    else 
        $SCRIPT_DIR/backup_config.sh -k $KEY -p $PORT -u admin -s $HOSTNAME -f $PFNAME
    fi
    if [ $? -ne 0 ]; then
        echoerr "Error downloading backup for ${PFNAME} @ ${HOSTNAME}";
        echo "Continuing...";
    fi
done <<< "$(tail +2 "$FILE")" 
echo 0;