#!/bin/bash

# finds metadata AND spectral data AND loudness data - outputs in JSON format - JSON is kind of ugly
output_file=".ffmpeg_data.txt"
filename=""

path=$1

# shopt turn case insensitivity ON
shopt -s nocaseglob
shopt -s nullglob
for file in $path*.{wav,mp3,aif}; do
    # main command - analysis done here
    meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
    spectral_stats=$(ffmpeg -hide_banner -i "$file" -af aspectralstats=measure=all:win_size=16384,ametadata=print:file=- -f null - > "$output_file")

    # parses frame number from data - needed to adapt to any file length
    #frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' "$output_file")

    # parses spectral centroid value from up to 8 channels and returns the mean value
    centroid_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.centroid" { print $2/20000 }' "$output_file")
    centroid_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.centroid" { print $2/20000 }' "$output_file")

    variance_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.variance" { print $2*1000000 }' "$output_file")
    variance_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.variance" { print $2*1000000 }' "$output_file")

    spread_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.spread" { print $2/10000 }' "$output_file")
    spread_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.spread" { print $2/10000 }' "$output_file")

    skewness_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.skewness" { print $2/50 }' "$output_file")
    skewness_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.skewness" { print $2/50 }' "$output_file")

    kurtosis_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.kurtosis" { print $2/1000 }' "$output_file")
    kurtosis_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.kurtosis" { print $2/1000 }' "$output_file")

    entropy_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.entropy" { print $2*0.5 }' "$output_file")
    entropy_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.entropy" { print $2*0.5 }' "$output_file")

    flatness_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.flatness" { print $2 }' "$output_file")
    flatness_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.flatness" { print $2 }' "$output_file")

    crest_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.crest" { print $2/2000 }' "$output_file")
    crest_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.crest" { print $2/2000 }' "$output_file")

    flux_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.flux" { print $2*10 }' "$output_file")
    flux_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.flux" { print $2*10 }' "$output_file")

    slope_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.slope" { print $2*-1000 }' "$output_file")
    slope_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.slope" { print $2*-1000 }' "$output_file")

    decrease_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.decrease" { print $2*10 }' "$output_file")
    decrease_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.decrease" { print $2*10 }' "$output_file")

    rolloff_1=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.1.rolloff" { print $2/20000 }' "$output_file")
    rolloff_2=$(echo "$spectral_stats" | awk -F'=' '$1 == "lavfi.aspectralstats.2.rolloff" { print $2/20000 }' "$output_file")

    filename="$file"

    echo "$centroid_1" >> ".centroid_l.txt"
    echo "$centroid_2" >> ".centroid_r.txt"
    echo "$variance_1" >> ".variance_l.txt"
    echo "$variance_2" >> ".variance_r.txt"
    echo "$spread_1" >> ".spread_l.txt"
    echo "$spread_2" >> ".spread_r.txt"
    echo "$skewness_1" >> ".skewness_l.txt"
    echo "$skewness_2" >> ".skewness_r.txt"
    echo "$kurtosis_1" >> ".kurtosis_l.txt"
    echo "$kurtosis_2" >> ".kurtosis_r.txt"
    echo "$entropy_1" >> ".entropy_l.txt"
    echo "$entropy_2" >> ".entropy_r.txt"
    echo "$flatness_1" >> ".flatness_l.txt"
    echo "$flatness_2" >> ".flatness_r.txt"
    echo "$crest_1" >> ".crest_l.txt"
    echo "$crest_2" >> ".crest_r.txt"
    echo "$flux_1" >> ".flux_l.txt"
    echo "$flux_2" >> ".flux_r.txt"
    echo "$slope_1" >> ".slope_l.txt"
    echo "$slope_2" >> ".slope_r.txt"
    echo "$decrease_1" >> ".decrease_l.txt"
    echo "$decrease_2" >> ".decrease_r.txt"
    echo "$rolloff_1" >> ".rolloff_l.txt"
    echo "$rolloff_2" >> ".rolloff_r.txt"

    # graph
    gnuplot -e "arg='$filename.png'" -p .graph-time.sh

    # remove files
    rm ".centroid_l.txt"
    rm ".centroid_r.txt"
    rm ".variance_l.txt"
    rm ".variance_r.txt"
    rm ".spread_l.txt"
    rm ".spread_r.txt"
    rm ".skewness_l.txt"
    rm ".skewness_r.txt"
    rm ".kurtosis_l.txt"
    rm ".kurtosis_r.txt"
    rm ".entropy_l.txt"
    rm ".entropy_r.txt"
    rm ".flatness_l.txt"
    rm ".flatness_r.txt"
    rm ".crest_l.txt"
    rm ".crest_r.txt"
    rm ".flux_l.txt"
    rm ".flux_r.txt"
    rm ".slope_l.txt"
    rm ".slope_r.txt"
    rm ".decrease_l.txt"
    rm ".decrease_r.txt"
    rm ".rolloff_l.txt"
    rm ".rolloff_r.txt"

done
shopt -u nocaseglob

rm "$output_file"