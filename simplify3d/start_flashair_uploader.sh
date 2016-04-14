#!/bin/bash 

# NOTE: working directory is established by the caller. If need a specific
# directory, make sure to set it here.

# Network address of the Flashair SD card.
flashair_ip="192.168.0.8"

# Abort the script is it's running longer than this time in secs.
timeout_secs=60

# Process command line args.
gcode="$1"
x3g="${gcode/%gcode/x3g}"

echo "gcode: [${gcode}]"
echo "x3g: [${x3g}]"

last_notification=""

function notification {
  echo $1
  if [ "$last_notification" != "$1" ]
  then
    last_notification="$1"
    /usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message "$last_notification"
  fi
}

function main {
  start_time=$(date +%s)
  
  last_size=0
  while true
  do
  
    echo
    echo ==========================
  
    time_now=$(date +%s)
    running_time=$((time_now - $start_time))
  
    sleep 0.5
  
    echo "---- loop, running_time=$running_time, last_size=${last_size}, stable_count=${stable_count}"
  
    if [[ $running_time -ge 60 ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'TIMEOUT, aborting'
      notification 'TIMEOUT, aborting'
      echo "Timeout, aborting"
      exit 1
    fi
  
    ls -l ${gcode/%gcode/*}
  
    if [[ ! -f "${x3g}" ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'Waiting for creation'
      notification 'Waiting for creation'
      echo "X3G gile not found"
      last_size=0
      stable_count=0
      continue
    fi
  
    gcode_time=$(stat -f%m "$gcode")
    x3g_time=$(stat -f%m "$x3g")
    if [[ "$x3g_time" -lt "$gcode_time" ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'Waiting for new file'
      notification 'Waiting for new file'
      echo "X3G file is older than gcode"
      last_size=$size
      stable_count=0
      continue
    fi
  
    size=$(stat -f%z "$x3g")
    echo "New size: ${size}"
    if [[ "$size" -eq 0 ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'Waiting for non zero size'
      notification 'Waiting for non zero size'
      echo "X3G file has zero size"
      last_size=$size
      stable_count=0
      continue
    fi
  
    if [[  "$size" -ne $last_size ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'Waiting for size stabilization'
      notification 'Waiting for size stabilization'
      echo "X3G file has zero or unstable size"
      last_size=$size
      stable_count=0
      continue
    fi
    
    ((stable_count++))
    # TODO: Revisit this limit. From experience stable 3secs are sufficient. 
    if [[ $stable_count = 6 ]]
    then
      #/usr/local/bin/terminal-notifier -group 'x3g_uploader' -title 'Flashair Upload' -message 'File is stable'
      notification 'File is stable'
      echo "Stable"
      break
    fi
  done
  
  notification 'Starting to upload...'
  curl -v \
    -F "userid=1" \
    -F "filecomment=This is a 3D file" \
    -F "image=@${x3g}" \
    192.168.0.8/upload.cgi
  
  echo "Status: $?"
  
  notification 'Uploading done'
}

main &>/tmp/flashair_uploader_log &

echo running in background.

