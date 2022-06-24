#!/bin/bash
set -e

# constants
readonly VARS_PATH="./group_vars/beef/vars"

function assign_udf_vars {
  # write vars file
  sed 's/  //g' <<EOF > ${VARS_PATH}
  # linode vars
  # sudo user
  beefpassword: ${BEEFPASSWORD}
  soa_email_address: ${SOA_EMAIL_ADDRESS}
  username: ${USERNAME}
  password: ${PASSWORD}
  pubkey: ${PUBKEY}
  disable_root: ${DISABLE_ROOT}
  token_password: ${TOKEN_PASSWORD}
  subdomain: ${SUBDOMAIN}
  domain: ${DOMAIN}
EOF
}

function run_playbook {
  ansible-playbook -vvv site.yml
}

# main
case $1 in
    assign_udf_vars) "$@"; exit;;
    run_playbook) "$@"; exit;;
esac
