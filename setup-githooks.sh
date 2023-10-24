#!/usr/bin/env bash

set -euo pipefail

########
# VARS #
########
HOOKFILE='simple-sops/helpers/githooks/pre-commit-check-for-unencrypted'

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

if [[ -e "${GITHOOK_DIR}/pre-commit" ]]; then
  echo "File \"${GITHOOK_DIR}/pre-commit\" exists. Aborting" >&2
  exit 2
else
  echo "creating link: ${GITHOOK_DIR}/pre-commit -> ${HOOKFILE} "
  ln -s "${RELATIVE_PATH}/${HOOKFILE}" "${GITHOOK_DIR}/pre-commit"
fi
