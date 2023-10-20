#!/usr/bin/env bash

###########
# OPTARGS #
###########

declare SOPS_LIST_FILE

while getopts ":f:" opt; do
  case ${opt} in
    f )
      SOPS_LIST_FILE="${OPTARG}"
      ;;
    \?|* )
      echo "Invalid option -${OPTARG}" 1>&2
      ;;
  esac
done

shift $((OPTIND -1))

SOPS_LIST_FILE="${SOPS_LIST_FILE-.simple-sops-managed-files}"

########
# ARGS #
########

declare COMMAND
case "${1}" in
  encrypt)
    COMMAND="encrypt-file"
    ;;
  decrypt)
    COMMAND="decrypt-file"
    ;;
  *)
    echo "ERROR: Only accepts 'encrypt' or 'decrypt' as an argument" >&2
    exit 3
    ;;
esac


########
# VARS #
########

declare -a FILES_TO_MARSHAL
mapfile -t FILES_TO_MARSHAL < "${SOPS_LIST_FILE}"

#declare ENCRYPTION_DETERMINATE
#ENCRYPTION_DETERMINATE=' *.+: "?ENC\[.*\]"?,?$' # regex

# Capture the path of `is-sops-encrypted.sh`, relative to the script location
# and not the current working directory. (Note: symlinks not accounted for)
declare IS_SOPS_ENCRYPTED
IS_SOPS_ENCRYPTED=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/helpers/is-sops-encrypted.sh

#############
# FUNCTIONS #
#############

function encrypt-file {
  local FILE
  FILE="${1}"
  if "${IS_SOPS_ENCRYPTED}" "${FILE}"; then
    echo "${FILE}": encrypted, skipping
  else
    echo -n "${FILE}": encrypting ...
    set -e
    sops --encrypt --in-place "${FILE}"
    set +e
    echo ' done'
  fi
}

function decrypt-file {
  local FILE
  FILE="${1}"
  if "${IS_SOPS_ENCRYPTED}" "${FILE}"; then
    echo -n "${FILE}": decrypting ...
    set -e
    sops --decrypt --in-place "${FILE}"
    set +e
    echo ' done'
  else
    echo "${FILE}": not encrypted, skipping
  fi
}

########
# MAIN #
########

for i in "${FILES_TO_MARSHAL[@]}"; do
  "${COMMAND}" "${i}"
done

