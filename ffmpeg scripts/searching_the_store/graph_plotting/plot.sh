#!/bin/bash

# log usage
#echo "Usage: $0 <type: 'file' or 'feature'> <file or feature to use>"

# create files for this
graph_file=".graph_file.txt"
sort_file=".sorting_data.txt"

# Extract the arguments
type="$1"
argument="$2"

# overwrite the .txt file for graph data
echo " " > "$graph_file"

if [ "$type" == "file" ]; then
    # Extract and sort the values for the specified measurement
    grep "$argument" "$sort_file" | awk -F':' '{
        if ($3 > 1. && $3 < 50.)
            print $2, ($3/50.);
        else if ($3 > 50. && $3 < 10000.)
            print $2, ($3/10000.);
        else if ($3 > 10000. && $3 < 20000.)
            print $2, ($3/20000.);
        else if ($3 > 0 && $3 < 0.0000001)
            print $2, ($3*5000000.);
        else if ($3 < 0. && $3 > -0.0001)
            print $2, ($3*-5000.);
        else if ($3 < -0.01 && $3 > -1.)
            print $2, $3*-1.5;
        else if ($3 < -1.)
            print $2, ($3/-96.);
        else print $2, $3
        }' | sort -n >> "$graph_file"

    # graph
    gnuplot -e "arg='$argument.png'" -p .graph.sh

elif [ "$type" == "feature" ]; then
    # Extract and sort the values for the specified measurement
    grep "$argument" "$sort_file" | awk -F':' '{
        if ($3 > 1. && $3 < 50.)
            print $1, ($3/50);
        else if ($3 > 50. && $3 < 10000.)
            print $1, ($3/10000.);
        else if ($3 > 10000. && $3 < 20000.)
            print $1, ($3/20000.);
        else if ($3 > 0. && $3 < 0.0000001)
            print $1, ($3*5000000.);
        else if ($3 < 0. && $3 > -0.0001)
            print $1, ($3*-5000.);
        else if ($3 < -0.0001 && $3 > -1.)
            print $1, $3*-1;
        else if ($3 < -1.)
            print $1, ($3/-96.);
        else print $1, $3
        }' | sort -n >> "$graph_file"

    # graph
    gnuplot -e "arg='$argument.png'" -p .graph.sh
        
else
    # Handle the case where the wrong number of arguments is provided
    echo "Usage: $0 <type: 'file' or 'feature'> <file or feature to use>"
    exit 1
fi
