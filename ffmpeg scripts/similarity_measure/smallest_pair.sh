#!/bin/bash

# run on 'output_file.txt' after calculating pair differences in 'similar_auto or man' files

# Check if a file argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input_file.txt>"
  exit 1
fi

input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file '$input_file' not found."
  exit 1
fi

# Initialize variables to store the minimum absolute difference and the corresponding file names
min_absolute_difference=999999999  # Initialize with a large value
file1=""
file2=""

# Loop through the lines in the input file
while read -r line; do
  # Extract the relevant information from each line
  file_names=$(echo "$line" | cut -d ':' -f 1)
  absolute_difference=$(echo "$line" | awk '{print $NF}')
  
  # Compare the absolute difference with the current minimum
  if (( $(bc <<< "$absolute_difference < $min_absolute_difference") )); then
    min_absolute_difference=$absolute_difference
    file1=$(echo "$file_names" | cut -d ' ' -f 1)
    file2=$(echo "$file_names" | cut -d ' ' -f 3)
  fi
done < "$input_file"

# Print the pair of file names with the smallest absolute difference
echo "Smallest Absolute Difference: $min_absolute_difference"
echo "File Pair: $file1 vs $file2"
