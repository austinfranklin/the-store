#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <audio_file> <measurement_to_sort>"
    exit 1
fi

# Extract the arguments
text_file=".output_data.txt"
audio_file="$1.json"
measurement_to_sort="$2"

# Extract and sort the absolute differences for the specified audio file and measurement
grep -w "$audio_file" "$text_file" | grep "$measurement_to_sort" | awk -F 'Absolute Difference: ' '{print $2, $1}' | sort -n
