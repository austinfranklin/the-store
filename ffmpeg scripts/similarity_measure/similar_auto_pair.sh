#!/bin/bash

output_file="output_file.txt"

# Check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
  echo "Error: jq is not installed. Please install jq first."
  exit 1
fi

# Check if at least one key is provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 -k <key1> [<key2> ...]"
  exit 1
fi

# Parse the arguments
keys=()
key_flag=false

for arg in "$@"; do
  if [ "$arg" == "-k" ]; then
    key_flag=true
  elif [ "$key_flag" == "true" ]; then
    keys+=("$arg")
    key_flag=false
  fi
done

# Function to extract JSON values
get_json_value() {
  local file="$1"
  local key="$2"
  local value
  value=$(jq -r ".$key" "$file")
  echo "$value"
}

# Get a list of all JSON files in the current directory
json_files=(*.json)

# Calculate similarity for each pair of files and keys
for ((i = 0; i < ${#json_files[@]}; i++)); do
  for ((j = i + 1; j < ${#json_files[@]}; j++)); do
    file1="${json_files[$i]}"
    file2="${json_files[$j]}"
    similarity=0

    for key in "${keys[@]}"; do
      value1=$(get_json_value "$file1" "$key")
      value2=$(get_json_value "$file2" "$key")

      diff=$(echo "$value1 - $value2" | bc -l)
      diff_abs=$(echo "$diff" | awk '{print ($1 < 0) ? -$1 : $1}')

      echo "$file1 vs $file2: $key: $value1 (File1), $value2 (File2), Absolute Difference: $diff_abs" >> "$output_file"
      similarity=$(echo "$similarity + $diff_abs" | bc -l)
    done

    #echo "$file1 vs $file2: Total Similarity: $similarity"
  done
done

# Initialize variables to store the minimum absolute difference and the corresponding file names
min_absolute_difference=99999999999999  # Initialize with a large value
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
done < "$output_file"

# Print the pair of file names with the smallest absolute difference
echo "Smallest Absolute Difference: $min_absolute_difference"
echo "File Pair: $file1 vs $file2"