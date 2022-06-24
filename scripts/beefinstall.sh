#!/bin/bash
set -e

## Deployment Variables
# Script to install BEEF on Linode
# <UDF name="beefpassword" Label="BEEF Password" />
# <UDF name="soa_email_address" label="Email address (for the Let's Encrypt SSL certificate)" example="user@domain.tld">

## Linode/SSH Security Settings
#<UDF name="username" label="The limited sudo user to be created for the Linode. The username cannot contain any spaces or capital letters. For this application the username 'beef' is reserved for the application, so please choose an alternative username for this deployment." default="">
#<UDF name="password" label="The password for the limited sudo user" example="an0th3r_s3cure_p4ssw0rd" default="">
#<UDF name="pubkey" label="The SSH Public Key that will be used to access the Linode" default="">
#<UDF name="disable_root" label="Disable root access over SSH?" oneOf="Yes,No" default="No">

## Domain Settings
#<UDF name="token_password" label="Your Linode API token. This is needed to create your WordPress server's DNS records" default="">
#<UDF name="subdomain" label="Subdomain" example="The subdomain for the DNS record: www (Requires Domain)" default="">
#<UDF name="domain" label="Domain" example="The domain for the DNS record: example.com (Requires API token)" default="">

# git repo
export GIT_REPO="https://github.com/josephcardillo/ansible_beef.git"

# constants
readonly VARS_PATH="./group_vars/beef/vars"

# enable logging
set -o pipefail
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1

function setup {
  # install dependancies
  apt-get update
  apt-get install -y jq git python3 python3-pip python3-dev build-essential
  # write authorized_keys file
  #if [ "${ADD_SSH_KEYS}" == "yes" ]; then
  #  curl -sH "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN_PASSWORD}" https://api.linode.com/v4/profile/sshkeys | jq -r .data[].ssh_key > /root/.ssh/authorized_keys
  #fi
  # clone repo and set up ansible environment
  git clone ${GIT_REPO} /tmp/beef || echo "[FATAL] unable to pull repo" && exit 1
  cd /tmp/beef
  # pip3 install virtualenv
  # python3 -m virtualenv env
  # source env/bin/activate
  # pip install pip --upgrade
  # pip install -r requirements.txt
  # ansible-galaxy install -r collections.yml
  # copy run script to path
  cp scripts/run.sh /usr/local/bin/run
  chmod +x /usr/local/bin/run
}

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
setup
assign_udf_vars
run_playbook && export SUCCESS="true"
