#!/usr/bin/env bash

set -euo pipefail

##############
# EARLY EXIT #
##############

# if sops is already present, exit
if [[ -x "$(command -v sops)" ]]; then
  echo "sops is already present in: " "$(command -v sops)"
  echo "skipping install . . ."
  exit 0
fi

########
# VARS #
########

binary_type="linux.amd64"
sops_version="v3.8.1"
sops_checksum="d6bf07fb61972127c9e0d622523124c2d81caf9f7971fb123228961021811697"

dst_dir='/usr/local/bin'

##############
# VALIDATION #
##############

if [[ -x "$(command -v wget)" ]]; then
  dl_bin='wget -nv -O-'
elif [[ -x "$(command -v curl)" ]]; then
  dl_bin='curl -s -L'
else
  echo 'Missing wget or curl: This script requires wget or curl to run. Aborting' >&2
  exit 2
fi
if [[ -x "$(command -v shasum)" ]]; then
  : # pass
else
  echo 'Missing shasum: This script requires perl or libdigest-sha-perl to run. Aborting' >&2
  exit 2
fi

#############
# FUNCTIONS #
#############

function install-sops {
  echo 'Installing sops...'
  $dl_bin github.com/getsops/sops/releases/download/${sops_version}/sops-${sops_version}.${binary_type} > /tmp/sops
  echo "${sops_checksum}  /tmp/sops" | shasum -c -
  mv /tmp/sops ${dst_dir}/sops
  chmod +x ${dst_dir}/sops
  echo "Installed ${dst_dir}/sops ${sops_version}"
}

########
# MAIN #
########

# Redundant check
# if sops is not present in "${dst_dir}/sops" then install it
if [[ ! -x "${dst_dir}/sops" ]]; then
  install-sops
else
  echo "sops is already present in ${dst_dir}/sops"
  echo 'skipping install . . .'
  exit 0
fi

