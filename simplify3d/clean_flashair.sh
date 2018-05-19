#!/bin/bash 

# Delete all x3g files on the flashair.

# Network address of the Flashair SD card. Customize as needed.
flashair_ip="10.0.0.8"

# Set to -v to have curl verbose output, -s for silent
curl_verbosity="-s"
#curl_verbosity="-v"

# Temp files prefix
tmp_prefix="/tmp/flashair_delete"

# Call just after involing a command. 
# arg1: command name/description.
function check_last_cmd() {
  status="$?"
  if [ "$status" -ne "0" ]; then
    echo "FAILED: $1"
    exit 1
  fi
}

# Read file list. Store them in given output file path.
function read_file_list() {
  output_file="$1"
  tmp_file="${tmp_prefix}_rfl_1"
  curl ${curl_verbosity} \
    --connect-timeout 5 \
    --output ${tmp_file} \
    "${flashair_ip}/command.cgi?op=100&DIR=/"
  check_last_cmd "Listing files"
  
  # Filter out the x3 file names
  tail +2 ${tmp_file} | cut -d, -f2 | grep '.x3g$' > ${output_file}
}


# Delete given file on flashair.
function delete_file() {
  fname=$1
  echo "Deleting ${fname}"

  curl ${curl_verbosity} \
    --connect-timeout 5 \
    "${flashair_ip}/upload.cgi?DEL=/${fname}"
  check_last_cmd "Deleting ${fname}"

  echo
}

function main() {
  tmp_file_list="${tmp_prefix}.main.1"
 
  echo "Reading flashair file list"  
  read_file_list $tmp_file_list

  # Read the file into an array
  oifs=$IFS # save a copy of the input field separator character list
  IFS=$'\n' arr=( $(< $tmp_file_list) )
  IFS=$oifs # restore
  #echo "${arr[@]}"
  echo "Found ${#arr[@]} .x3g files."
  
  for fname in "${arr[@]}"
  do
    echo
    echo -e -n "Delete/keep \033[1;34m${fname}\033[0m "
    read -n1 -r -p "[d/K] " response
    echo
    if [[ $response =~ ^([dD])$ ]]
    then
      delete_file $fname
    else
      echo "User said keep"
    fi
  done

  echo
  echo "All done."
}

main
