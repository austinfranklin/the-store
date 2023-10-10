#!/bin/bash

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

      echo "$file1 vs $file2: $key: $value1 (File1), $value2 (File2), Absolute Difference: $diff_abs"
      similarity=$(echo "$similarity + $diff_abs" | bc -l)
    done

    #echo "$file1 vs $file2: Total Similarity: $similarity"
  done
done
