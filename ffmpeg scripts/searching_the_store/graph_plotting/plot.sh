#!/bin/bash

# log usage
#echo "Usage: $0 <type: 'file' or 'feature'> <file or feature to use>"

# create files for this
graph_file=".graph_file.txt"
sort_file=".sorting_data.txt"
debug="debugging.txt"

# Extract the arguments
type="$1"
argument="$2"

# overwrite the .txt file for graph data
echo " " > "$graph_file"

if [ "$type" == "file" ]; then
    # Extract and sort the values for the specified measurement
    grep "$argument" "$sort_file" | awk -F': ' '{
        if ($2 == "spectral.centroid.ch1" || $2 == "spectral.centroid.ch2" || $2 == "spectral.rolloff.ch1" || $2 == "spectral.rolloff.ch2")
            print $2, $3/20000;
        if ($2 == "spectral.spread.ch1" || $2 == "spectral.spread.ch2")
            print $2, $3/10000;
        if ($2 == "spectral.crest.ch1" || $2 == "spectral.crest.ch2")
            print $2, $3/2000;
        if ($2 == "spectral.kurtosis.ch1" || $2 == "spectral.kurtosis.ch2")
            print $2, $3/1000;
        if ($2 == "spectral.skewness.ch1" || $2 == "spectral.skewness.ch2")
            print $2, $3/50;
        if ($2 == "spectral.entropy.ch1" || $2 == "spectral.entropy.ch2" || $2 == "spectral.flatness.ch1" || $2 == "spectral.flatness.ch2")
            print $2, $3;
        if ($2 == "spectral.decrease.ch1" || $2 == "spectral.decrease.ch2" || $2 == "spectral.flux.ch1" || $2 == "spectral.flux.ch2")
            print $2, $3*10;
        if ($2 == "spectral.variance.ch1" || $2 == "spectral.variance.ch2")
            print $2, $3*1000000;
        if ($2 == "spectral.slope.ch1" || $2 == "spectral.slope.ch2")
            print $2, $3*-1000;
        if ($2 == "loudness.max_volume" || $2 == "loudness.mean_volume" || $2 == "loudness.integrated_lufs" || $2 == "loudness.threshold")
            print $2, ($3+96)/96;
        if ($2 == "loudness.lra")
            print $2, $3/48;
        }' | sort -n >> "$graph_file"

    # graph
    gnuplot -e "arg='$argument.png'" -p .graph.sh

elif [ "$type" == "feature" ]; then
    # Extract and sort the values for the specified measurement
    grep "$argument" "$sort_file" | awk -F': ' '{
        if ($2 == "spectral.centroid.ch1" || $2 == "spectral.centroid.ch2" || $2 == "spectral.rolloff.ch1" || $2 == "spectral.rolloff.ch2")
            print $1, $3/20000;
        if ($2 == "spectral.spread.ch1" || $2 == "spectral.spread.ch2")
            print $1, $3/10000;
        if ($2 == "spectral.crest.ch1" || $2 == "spectral.crest.ch2")
            print $1, $3/2000;
        if ($2 == "spectral.kurtosis.ch1" || $2 == "spectral.kurtosis.ch2")
            print $1, $3/1000;
        if ($2 == "spectral.skewness.ch1" || $2 == "spectral.skewness.ch2")
            print $1, $3/50;
        if ($2 == "spectral.entropy.ch1" || $2 == "spectral.entropy.ch2" || $2 == "spectral.flatness.ch1" || $2 == "spectral.flatness.ch2")
            print $1, $3;
        if ($2 == "spectral.decrease.ch1" || $2 == "spectral.decrease.ch2" || $2 == "spectral.flux.ch1" || $2 == "spectral.flux.ch2")
            print $1, $3*10;
        if ($2 == "spectral.variance.ch1" || $2 == "spectral.variance.ch2")
            print $1, $3*1000000;
        if ($2 == "spectral.slope.ch1" || $2 == "spectral.slope.ch2")
            print $1, $3*-1000;
        if ($2 == "loudness.max_volume" || $2 == "loudness.mean_volume" || $2 == "loudness.integrated_lufs" || $2 == "loudness.threshold")
            print $1, ($3+96)/96;
        if ($2 == "loudness.lra")
            print $1, $3/48;
        }' | sort -n >> "$graph_file"

    # graph
    gnuplot -e "arg='$argument.png'" -p .graph.sh
        
else
    # Handle the case where the wrong number of arguments is provided
    echo "Usage: $0 <type: 'file' or 'feature'> <file or feature to use>"
    exit 1
fi
