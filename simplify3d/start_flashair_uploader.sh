#!/bin/bash 

# Usage
# Add this line in the Simplify3D "Additional terminal commands for post processing" field.
# <path to this file> [output_filepath]

# NOTE: working directory is established by the caller. If need a specific
# directory, make sure to set it here.

# TODO: assert on curl results.
# TODO: force curl timeout.
# TODO: include file name/size in the notification
# TODO: include upload time in notification.
# TODO: include useful info in error notifications (e.g. log file).
# TODO: tie notification clicks to log file
# TODO: replace literals with consts
# TODO: include instructions for setting up the Flashair card.

# Change banner time. This is persistent and affects all banners.
# TODO: is there a way to extend the banner time just for this script?
defaults write com.apple.notificationcenterui bannerTime 60 

# Network address of the Flashair SD card.
flashair_ip="192.168.0.8"

# Abort the script if the x3g file is not ready for uploading within
# this time in secs from the launch of this script.
# NOTE: this may require user login/out or even OS reboot to take affect.
wait_timeout_secs=60


# Called upon script starts. Accepts command line args.
function init {
  # Process command line args.
  gcode_path="$1"
  x3g_path="${gcode_path/%gcode/x3g}"
  x3g_name=$(basename "${x3g_path}")
  
  echo "gcode_path: [${gcode_path}]"
  echo "x3g_path: [${x3g_path}]"
  echo "x3g_name: [${x3g_name}]"
}


# Max OSX specific display popup notification. 
# Required installation of terminal-notifier.
function notification {
  echo $1
  echo $2
  if [ "$last_notification" != "$1#$2" ]
  then
    last_notification="$1#$2"
    /usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Uploader' -subtitle "$1" -message "$2"
  fi
}


# Return the current date/time as a FAT32 timestamp (a string with
# 8 hex characters)
function fat32_timestamp {
  # Get current date
  local date=$(date "+%-y,%-m,%-d,%-H,%-M,%-S")

  # Split to tokens
  # TODO: make tokens variable local.
  IFS=',' read -ra tokens <<< "$date"
  local YY="${tokens[0]}"
  local MM="${tokens[1]}"
  local DD="${tokens[2]}"
  local hh="${tokens[3]}"
  local mm="${tokens[4]}"
  local ss="${tokens[5]}"

  # Compute timestamp (8 hex chars)
  local fat32_date=$((DD + 32*MM + 512*(YY+20)))
  local fat32_time=$((ss/2 + 32*mm + 2048*hh))
  printf "%04x%04x" $fat32_date $fat32_time
}

# Simplify3D post processing hook is brain dead when it uses X3G output
# file format. The terminal command postprocessing script it calls 
# before the X3G file is ready or requires the user to apply heiuristics
# to determine when the generation fo the X3G file is complete.
# This function uses such heiuristics and blocks until the X3G file 
# is ready or until a timeout, whichever occurs first.
function wait_x3g_file_ready {
  notification "Waiting" "Waiting for file: ${x3g_name}"

  local start_time=$(date +%s)
  
  local last_size=0
  while true
  do
  
    echo
    echo ==========================
  
    local time_now=$(date +%s)
    local running_time=$((time_now - $start_time))
  
    sleep 0.5
  
    echo "---- loop, running_time=$running_time, last_size=${last_size}, stable_count=${stable_count}"
  
    if [[ $running_time -ge $wait_timeout_secs ]]
    then
      notification "ERROR" "Aborted due to timeout: ${x3g_name}"
      echo "Timeout, aborting"
      exit 1
    fi
  
    ls -l ${gcode_path/%gcode/*}
  
    if [[ ! -f "${x3g_path}" ]]
    then
      #notification "Waiting" "Waiting for file creation: ${x3g_name}"
      echo "X3G gile not found"
      last_size=0
      stable_count=0
      continue
    fi
  
    # NOTE: the stat format may be specific to OSX (?).
    local gcode_time=$(stat -f%m "$gcode_path")
    local x3g_time=$(stat -f%m "$x3g_path")
    if [[ "$x3g_time" -lt "$gcode_time" ]]
    then
      #notification "Waiting" "Waiting for a newer file: ${x3g_name}"
      echo "X3G file is older than gcode"
      last_size=$size
      stable_count=0
      continue
    fi
  
    # NOTE: the stat format may be specific to OSX (?).
    size=$(stat -f%z "$x3g_path")
    echo "New size: ${size}"
    if [[ "$size" -eq 0 ]]
    then
      #notification "Waiting" "Waiting for non zero size: ${x3g_name}"
      echo "X3G file has zero size"
      last_size=$size
      stable_count=0
      continue
    fi
  
    if [[  "$size" -ne $last_size ]]
    then
      #notification "Waiting" "Waiting for file size stabilization: ${x3g_name}"
      echo "X3G file has zero or unstable size"
      last_size=$size
      stable_count=0
      continue
    fi
    
    ((stable_count++))
    # TODO: Revisit this limit. From experience stable 3secs are sufficient. 
    if [[ $stable_count = 6 ]]
    then
      #notification "File ready", "File size is ${size}: ${x3g_name}"
      echo "Stable"
      break
    fi
  done
}


function main {
  init $*

  wait_x3g_file_ready

  local fat32_timestamp=$(fat32_timestamp)
  #notification "Uploading" "Sending file data..."

  # This notification should be replaced quickly with the Uploading
  # notification below. If not, it indicates that the Flashair card
  # is not available. Hence the 'Connecting' title.
  # The actual operation is setting the filetimestamp since the
  # FlashAir doesn't have and independent date/time source of its own.
  #
  notification "Connecting" "Setting file timestamp: ${x3g_name}"
  curl -v \
    ${flashair_ip}/upload.cgi?FTIME=0x${fat32_timestamp}
 
  notification "Uploading" "Sending file data..."
  curl -v \
    -F "userid=1" \
    -F "filecomment=This is a 3D file" \
    -F "image=@${x3g_path}" \
    ${flashair_ip}/upload.cgi
  
  echo "Status: $?"
  
  notification "DONE" "File uploaded to Flashair: ${size} ${x3g_name}"
}

main $* &>/tmp/flashair_uploader_log &
echo "Loader started in in background..."
