#!/usr/bin/env bash

set -euo pipefail

declare ENCRYPTION_DETERMINATE2 ENCRYPTION_DETERMINATE2

# Both must be true to be considered encrypted.
ENCRYPTION_DETERMINATE1=$'( |\t)*.+: "?ENC\[.*\]"?,?$'
ENCRYPTION_DETERMINATE2=$'^( |\t)*"?sops"?: ?\{?$'

declare -i rc

declare -i unencrypted_count
unencrypted_count=0

#############
# FUNCTIONS #
#############

function is-file-encrypted {
  local FILE
  FILE="${1}"
  if grep -E -q "${ENCRYPTION_DETERMINATE1}" "${FILE}" \
    && grep -E -q "${ENCRYPTION_DETERMINATE2}" "${FILE}"; then
      : # pass
  else
    unencrypted_count=$(( unencrypted_count + 1 ))
  fi
}

########
# MAIN #
########

for i in "${@}"; do
  is-file-encrypted "${i}"
done

if [[ ${unencrypted_count} -eq 0 ]]; then
  rc=0
else
  rc=${unencrypted_count}
fi

# the exit code is the number of files evaluated which were NOT encypted
exit ${rc}

