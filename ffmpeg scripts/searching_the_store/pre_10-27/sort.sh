#!/bin/bash

sim_file=".similar_data.txt"
sort_file=".sorting_data.txt"

# Check the number of arguments
if [  "$#" -eq 2 ]; then
    echo "Usage: $0 <audio_file> <measurement>"

    # Extract the arguments
    audio_file="$1.json"
    measurement="$2"

    # Extract and sort the absolute differences for the specified audio file and measurement
    grep -w "$audio_file" "$sim_file" | grep "$measurement" | awk -F 'Absolute Difference:' '{print $2, $1}' | sort -n
    exit 1
elif [  "$#" -eq 1 ]; then
    echo "Usage: $0 <measurement>"

    # Extract the arguments
    measurement="$1"

    # Extract and sort the values for the specified measurement
    grep "$measurement" "$sort_file" | awk -F':' '{print $3, $1, $2}' | sort -n
    exit 1
else
    # Handle the case where the wrong number of arguments is provided
    echo "Usage: $0 <audio_file> <measurement> (for two arguments) or $0 <measurement> (for one argument)"
    exit 1
fi