#!/usr/bin/env bash

set -e

##############
# EARLY EXIT #
##############

# if age is already present, exit
if [[ -x "$(command -v age)" ]]; then
  echo "age is already present in: " "$(command -v age)"
  echo "skipping install . . ."
  exit 0
fi

########
# VARS #
########

binary_type='linux-amd64'
age_version='v1.1.1'
age_checksum='0c6ddc31c276f55e9414fe27af4aada4579ce2fb824c1ec3f207873a77a49752'

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

function install-age {
  echo 'Installing age...'
  $dl_bin github.com/FiloSottile/age/releases/download/${age_version}/age-${age_version}-${binary_type}.tar.gz > /tmp/age.tar.gz
  tar -zxvf /tmp/age.tar.gz -C /tmp
  echo "${age_checksum}  /tmp/age/age" | shasum -c -
  mv /tmp/age/age ${dst_dir}/age
  chmod +x ${dst_dir}/age
  echo "Installed ${dst_dir}/age ${age_version}"
}

########
# MAIN #
########

# Redundant check
# if age is not present in "${dst_dir}/age" then install it
if [[ ! -x "${dst_dir}/age" ]]; then
  install-age
else
  echo "age is already present in ${dst_dir}/age"
  echo 'skipping install . . .'
  exit 0
fi

