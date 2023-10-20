#!/usr/bin/env bash

set -euo pipefail

########
# VARS #
########
HOOKFILES=( simple-sops/helpers/githooks/pre-commit-check-for-unencrypted )

RELATIVE_PATH='../..'

GITHOOK_DIR='.git/hooks'

##############
# VALIDATION #
##############
if [[ -d "${GITHOOK_DIR}" ]]; then
  : # pass
else
  echo "${GITHOOK_DIR} does not exist. Aborting" >&2
  exit 2
fi

for hook in "${HOOKFILES[@]}"; do
  if [[ -x "${hook}" ]]; then
    : # pass
  else
    echo "${hook} does not exist or is not executable. Aborting" >&2
    exit 2
  fi
done

#########
# MAIN #
#########
for i in "${HOOKFILES[@]}"; do
  echo "creating link: ${i} -> ${GITHOOK_DIR}/$(basename ${i})"
  ln -sf "${RELATIVE_PATH}/${i}" "${GITHOOK_DIR}/pre-commit"
done
