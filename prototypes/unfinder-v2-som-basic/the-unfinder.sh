#!/bin/bash

# finds metadata AND spectral data AND loudness data - outputs in JSON format - JSON is kind of ugly
output_file=".ffmpeg_data.txt"

# shopt turn case insensitivity ON
shopt -s nocaseglob
shopt -s nullglob
for file in $path*.{wav,mp3,aiff,aif,m4a,flac,ogg}; do
    filename="$file"
    pathname="$path"

    if [ -e ".$filename.json" ]; then
        echo "$filename"" already analyzed"
    else
        # main command - analysis done here
        meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
        spectral_stats=$(ffmpeg -hide_banner -i "$file" -af aspectralstats=measure=all:win_size=4096,ametadata=print:file=- -f null - > "$output_file")
        lufs_stats=$(ffmpeg -hide_banner -i "$file" -af ebur128=framelog=verbose -f null - 2>> "$output_file")
        volume_stats=$(ffmpeg -hide_banner -i "$file" -filter:a volumedetect -f null - 2>> "$output_file")

        # parses frame number from data - needed to adapt to any file length
        frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

        # parses overall lufs stats
        integrated=$(echo "$lufs_stats" | awk '/I:/ {print $2/-96}' "$output_file")
        #threshold=$(echo "$lufs_stats" | awk '/Threshold:/ {print $2}' "$output_file")
        lra=$(echo "$lufs_stats" | awk '/LRA:/ {print $2/96}' "$output_file")

        # parses volume stats
        mean_volume=$(echo "$volume_stats" | awk '/mean_volume:/ {print $5}' "$output_file")
        max_volume=$(echo "$volume_stats" | awk '/max_volume:/ {print $5}' "$output_file")

        # gets the centroid mean value
        centroid_mean=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {centroid_1 += $2} END {print (centroid_1/'"$frame_count"')/10000}' "$output_file")

        # gets the spread mean value
        spread_mean=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {spread_1 += $2} END {print (spread_1/'"$frame_count"')/10000}' "$output_file")

        # gets the flatness mean value
        flatness_mean=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {flatness_1 += $2} END {print flatness_1/'"$frame_count"'}' "$output_file")

        # gets the slope mean value
        slope_mean=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {slope_1 += $2} END {print (slope_1/'"$frame_count"')*-1000}' "$output_file")

        # gets the rolloff mean value
        rolloff_mean=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {rolloff_1 += $2} END {print (rolloff_1/'"$frame_count"')/20000}' "$output_file")

        echo '
{
    "metadata": '"$meta_stats"',
    "loudness": {
        "max_volume": '"$max_volume"',
        "mean_volume": '"$mean_volume"',
        "integrated_lufs": '"$integrated"',
        "lra": '"$lra"'
    },
    "path": "'"$pathname/$filename"'",
    "spectral": ['"$centroid_mean"', '"$spread_mean"', '"$flatness_mean"', '"$slope_mean"', '"$rolloff_mean"']
}' > ."$filename".json
    fi
done
shopt -u nocaseglob

rm "$output_file"
