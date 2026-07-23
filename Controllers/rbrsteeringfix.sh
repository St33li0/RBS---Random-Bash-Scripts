#!/bin/bash

# Thanks to orregoso on the rsf rbr discord for the base of the script

# Opts
filename="!No Filename Given!"
device_identifier_string="g29"
oversteer_path="/usr/bin/oversteer"

# CLI Opts
usage() {
  echo -n "$(basename $0) [OPTION]... [FILE]...

Description of this script.

 Required Options:
  -f, --filename    Set absolute path of rsfdata/logFile.txt

 Optionals
  -d, --device-id   Set string identifier for your device (case in-sensitive)
                      Default="g29"
  -o, --oversteer   Set absolute path of oversteer
                      Usually /usr/bin/ or /usr/local/bin/
                      If not there then set this var
                      (Also for if you have multiple binary files named oversteer)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Read options
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safe_exit ;;
    --version) out "$(basename $0) $version"; safe_exit ;;
    -f|--filename) shift; filename=$1 ;;
    -d|--device-id) shift; device_identifier_string=$1 ;;
    -o|--oversteer) shift; oversteer_path=$1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

trap "echo 'Stopped.'; exit 0" SIGINT

# Prevent duplicate instances
pgrep -f rbrsteeringfix.sh > /dev/null && exit 0

oversteer_path=$(whereis -b "oversteer" | sed 's/^oversteer: //')
device_path=$(oversteer --list |grep -i "$device_identifier_string" | sed -n 's/^  \(\/dev[^:]*\):.*/\1/p')

last_number=""

SECONDS=0

# Main loop
while true; do
# Check if the file exists
	if [ ! -f "$filename" ]; then
	  echo "Error: File '$filename' not found."
	  exit 1
	fi
  # Exit if game is no longer running
  if ! pgrep -f "RSF_Launcher.exe" > /dev/null; then
    echo "Game closed. Exiting script."
    "$oversteer_path" --device "$device_path" --range 900
	if [ "$SETTINGS" -gt 10 ]; then
      exit 0
	fi
  fi

  # Get last occurrence of "-r <number>"
  last_line=$(grep -Eo -- '-r [0-9]+' "$filename" | tail -n 1)

  # Extract the number after "-r"
  number=$(echo "$last_line" | awk '{print $2}')

  if [[ "$number" =~ ^[0-9]+$ ]]; then
    # Clamp value to 900 if >= 900
    [ "$number" -ge 900 ] && number=900

    if [ "$number" != "$last_number" ]; then
      "$oversteer_path" --device "$device_path" --range "$number"
      last_number="$number"
    fi
  fi

  sleep 1
done
