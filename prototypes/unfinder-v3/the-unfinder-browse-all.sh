#!/bin/bash

# Finds metadata, spectral data, and loudness data - outputs in JSON format

# Output folder on desktop
output_folder="$HOME/Desktop/audio-analysis"
mkdir -p "$output_folder"

source_names="$HOME/Desktop/audio-analysis/source_names.json"
source_paths="$HOME/Desktop/audio-analysis/source_paths.json"
source_analysis="$HOME/Desktop/audio-analysis/source_analysis.json"

# Temporary files to build JSON content
tmp_names=$(mktemp)
tmp_paths=$(mktemp)
tmp_analysis=$(mktemp)

echo '{' >> "$tmp_names"
echo '{' >> "$tmp_paths"
echo '{' >> "$tmp_analysis"

file_counter=0

# Temporary output file
output_file=$(mktemp)

# Shopt turn case insensitivity ON
shopt -s nocaseglob
shopt -s nullglob

# Loop through all directories and files. Change this to pick new directory
for dir in "$HOME"; do
    # Loop through each file in each subdirectory or directly on Desktop
    find "$dir" -type f | while read -r file; do
        extension="${file##*.}"  # Extract the extension
        filename="$(basename "$file")"  # Extract the filename
        pathname="$file"  # Extract the path

        echo "Processing: $file"  # Log the file being processed

        # Check if the file has a valid audio extension
        if [[ "$extension" =~ ^(wav|mp3|aiff|aif|m4a|flac|ogg)$ ]]; then
            echo "Valid audio file: $file"

            # Check if the file has already been analyzed
            if [ -e "$output_folder/$filename.json" ]; then
                echo "$filename already analyzed"
            else
                # Run the main analysis commands
                meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
                spectral_stats=$(ffmpeg -hide_banner -i "$file" -af aspectralstats=measure=all:win_size=32768,ametadata=print:file=- -f null - > "$output_file")
                lufs_stats=$(ffmpeg -hide_banner -i "$file" -af ebur128=framelog=verbose -f null - 2>> "$output_file")
                volume_stats=$(ffmpeg -hide_banner -i "$file" -filter:a volumedetect -f null - 2>> "$output_file")

                # Parses frame count from data
                frame_count=$(awk '/frame/ {count++} END {print count}' "$output_file")

                # Parses volume stats
                mean_volume=$(awk '/mean_volume:/ {print $5/-96}' "$output_file")
                max_volume=$(echo "$volume_stats" | awk '/max_volume:/ {print $5}' "$output_file")

                integrated=$(echo "$lufs_stats" | awk '/I:/ {print $2/-96}' "$output_file")
                lra=$(echo "$lufs_stats" | awk '/LRA:/ {print $2/96}' "$output_file")

                # Parses centroid mean value
                centroid_mean=$(awk -F"=" '/1.centroid/ {centroid_1 += $2} END {print (centroid_1/'"$frame_count"')/10000}' "$output_file")

                # Parses spread mean value
                spread_mean=$(awk -F"=" '/1.spread/ {spread_1 += $2} END {print (spread_1/'"$frame_count"')/10000}' "$output_file")

                # Parses skewness mean value
                skewness_mean=$(awk -F"=" '/1.skewness/ {skewness_1 += $2} END {print skewness_1/'"$frame_count"'}' "$output_file")

                # Parses flatness mean value
                flatness_mean=$(awk -F"=" '/1.flatness/ {flatness_1 += $2} END {print flatness_1/'"$frame_count"'}' "$output_file")

                # Parses kurtosis mean value
                kurtosis_mean=$(awk -F"=" '/1.kurtosis/ {kurtosis_1 += $2} END {print kurtosis_1/'"$frame_count"'}' "$output_file")

                # Parses entropy mean value
                entropy_mean=$(awk -F"=" '/1.entropy/ {entropy_1 += $2} END {print entropy_1/'"$frame_count"'}' "$output_file")

                # Parses crest mean value
                crest_mean=$(awk -F"=" '/1.crest/ {crest_1 += $2} END {print crest_1/'"$frame_count"'}' "$output_file")

                # Parses flux mean value
                flux_mean=$(awk -F"=" '/1.flux/ {flux_1 += $2} END {print flux_1/'"$frame_count"'}' "$output_file")

                # Parses slope mean value
                slope_mean=$(awk -F"=" '/1.slope/ {slope_1 += $2} END {print (slope_1/'"$frame_count"')*-1000}' "$output_file")

                # Parses rolloff mean value
                rolloff_mean=$(awk -F"=" '/1.rolloff/ {rolloff_1 += $2} END {print (rolloff_1/'"$frame_count"')/20000}' "$output_file")

                # Check if analysis was successful, if not ignore file
                if [ -z "$spread_mean" ] || [ -z "$mean_volume" ]; then
                    echo "Data not extracted correctly, ignoring file: $file"
                else
                    # Create the JSON output and write it to the output folder
                    echo '
                    {
                        "metadata": '"$meta_stats"',
                        "path": "'"$pathname"'",
                        "analysis": [ '"$spread_mean"', '"$skewness_mean"', '"$flatness_mean"', '"$kurtosis_mean"', '"$entropy_mean"', '"$crest_mean"', '"$flux_mean"', '"$slope_mean"', '"$rolloff_mean"', '"$mean_volume"' ]
                    }' > "$output_folder/.$filename.json"

                    # Append the data to the temporary files
                    # Filename
                    echo '"'$file_counter'" : [ "'$filename'" ],' >> "$tmp_names"

                    # Pathname
                    echo '"'$file_counter'" : [ "'$pathname'" ],' >> "$tmp_paths"

                    # Analysis
                    echo '"'$file_counter'" : [ '"$spread_mean"', '"$skewness_mean"', '"$flatness_mean"', '"$kurtosis_mean"', '"$entropy_mean"', '"$crest_mean"', '"$flux_mean"', '"$slope_mean"', '"$rolloff_mean"', '"$mean_volume"' ],' >> "$tmp_analysis"

                    # Increment the file counter
                    ((file_counter++))
                fi
            fi
        else
            echo "File not valid audio format: $file"
        fi
    done

# Function to remove trailing comma and close JSON object
remove_trailing_comma() {
    file="$1"
    # Read the file content
    content=$(cat "$file")
    # Remove the last comma before the closing brace
    content="${content%,}"  # This removes the trailing comma
    # Add closing brace
    echo "$content}" > "$file"
}

# Remove the trailing comma and close the JSON object
# Source names
remove_trailing_comma "$tmp_names"
mv "$tmp_names" "$source_names"

# Source paths
remove_trailing_comma "$tmp_paths"
mv "$tmp_paths" "$source_paths"

# Source analysis
remove_trailing_comma "$tmp_analysis"
mv "$tmp_analysis" "$source_analysis"


done

# Remove the temporary output file
rm "$output_file"

# shopt case insensitivity OFF
shopt -u nocaseglob
shopt -u nullglob
