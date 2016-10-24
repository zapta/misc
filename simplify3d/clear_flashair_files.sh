#!/bin/bash 

# Delete all x3g files on the flashair.

# Network address of the Flashair SD card. Customize as needed.
flashair_ip="192.168.0.8"

# Set to -v to have curl verbose output, -s for silent
curl_verbosity="-s"

# Temp files prefix
tmp_prefix="/tmp/flashair_delete"

# Call just after involing a command. 
# arg1: command name/description.
function check_last_cmd() {
  status="$?"
  if [ "$status" -ne "0" ]; then
    notification "FAILED" "$1"
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
  echo "Done"
}

function main() {
  tmp_file_list="${tmp_prefix}.main.1"
 
  echo "Reading flashair file list"  
  read_file_list tmp_file_list

  cat tmp_file_list | while read fname
  do
    delete_file $fname
  done
  echo "All done."
}

main
