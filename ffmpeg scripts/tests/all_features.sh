#!/bin/bash

graph_file=".graph_file.txt"

sim_file=".similar_data.txt"
sort_file=".sorting_data.txt"

echo "Usage: $0 <file>"

# Extract the arguments
audio_file=".$1.json"

# Extract and sort the values for the specified measurement
echo " " > "$graph_file"
grep "$audio_file" "$sort_file" | awk -F':' '{
    if ($3 > 50)
        print $2, ($3/20000);
    else if ($3 > 1 && $3 < 50)
        print $2, ($3/50);
    else if ($3 < -0.001 && $3 > -0.1) 
        print $2, ($3*-10);
    else if ($3 < -0.01 && $3 > -1)
        print $2, ($3*-.01)
    else if ($3 < -1)
        print $2, ($3*-.01)
    else if ($3 > -0.001 && $3 < 0.001)
        if ($3 < 0)
            print $2, ($3*-1000);
        else 
            print $2, ($3*1000);
    else
        print $2, $3
}' | sort -n >> "$graph_file"

# graph
gnuplot -p graph.sh "$1"
exit 1