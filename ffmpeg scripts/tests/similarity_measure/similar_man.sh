#!/bin/bash

# Check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
  echo "Error: jq is not installed. Please install jq first."
  exit 1
fi

# Check if at least two arguments are provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <file1.json> <file2.json> ... -k <key1> [<key2> ...]"
  exit 1
fi

# Parse the arguments
files=()
keys=()
key_flag=false

for arg in "$@"; do
  if [ "$arg" == "-k" ]; then
    key_flag=true
  elif [ "$key_flag" == "true" ]; then
    keys+=("$arg")
    key_flag=false
  else
    files+=("$arg")
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

# Calculate similarity for each pair of files and keys
for ((i = 0; i < ${#files[@]}; i++)); do
  for ((j = i + 1; j < ${#files[@]}; j++)); do
    file1="${files[$i]}"
    file2="${files[$j]}"
    similarity=0

    for key in "${keys[@]}"; do
      value1=$(get_json_value "$file1" "$key")
      value2=$(get_json_value "$file2" "$key")

      # Calculate the absolute difference using a conditional statement
      if [ $(echo "$value1 < $value2" | bc -l) -eq 1 ]; then
        diff=$(echo "$value2 - $value1" | bc -l)
      else
        diff=$(echo "$value1 - $value2" | bc -l)
      fi

      echo "$file1 vs $file2: $key: $value1 (File1), $value2 (File2), Absolute Difference: $diff"
      similarity=$(echo "$similarity + $diff" | bc -l)
    done

    echo "$file1 vs $file2: Total Similarity: $similarity"
  done
done
