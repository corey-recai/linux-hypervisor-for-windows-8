#!/bin/bash

OS_NAME=""
STEP=""

# helper function for sending the user error messages during script execution
function throw_upgrade_error {
  # if the exit status of the previously run function is not 0
  # then we have an unhandled error and should not move forward
  echo -e "\n/[ERROR] An error occured. The previous function exited with code $?. The package index was not sucessfully $STEP."
}

# helper function for sending the user success messages during script execution
function confirm {
  # if the exit status of the previously run function is 0
  # then we are able to continue running the script commands
  if [ $? == 0 ]; then
    echo -e "\n[SUCCESS] The package index has been sucessfully $STEP..."
  else
    # if the exit status of the previously run function is not 0
    # we will direct the script execution to the error handler
    throw_upgrade_error
  fi
}

function start_update {
  STEP="resynchronized"
  sudo apt-get update &&
    confirm
}

function start_upgrade {
  STEP="upgraded"
  sudo apt-get upgrade &&
    confirm
}

function update_apt {
  echo -e "\n[INFO] Resychronizing the package index for packages found in /etc/apt/packages.list...\n"
  start_update
}

function upgrade_apt {
  echo -e "\n[INFO] Upgrading the system packages found in /etc/apt/sources.list...\n"
  start_upgrade
}

function get_os_name {
  OS_NAME="$(cat /etc/os-release | grep -oP 'ID_LIKE=\K[^\n]*')"
}

function do_upgrade {
  case "$OS_NAME" in
    "debian")
      update_apt &&
        upgrade_apt
      ;;
    *)
      echo -e "[ERROR] Unsupported operating system."
      ;;
  esac
}

function install_build_dependencies {
  sudo apt-get install build-essential flex libncurses5-dev bc libelf-dev bison cpio
}

get_os_name &&
  do_upgrade

