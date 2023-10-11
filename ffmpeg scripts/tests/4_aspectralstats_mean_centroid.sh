# finds the mean spectral centroid of an audio file
# Input audio file
file="input.wav"

output_file="$HOME/Desktop/aspectralstats_mean.txt"

spectral_stats=$(ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -af aspectralstats=measure=centroid:win_size=2048,ametadata=print:file=- -f null - > "$output_file")

# parses frame number from data - needed to adapt to any file length
frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

# parses spectral centroid value from left and right channels
left_centroid=$(echo "$spectral_stats" | grep "centroid" "$output_file" | awk -F"=" '{sum += $2} END {print sum/'"$frame_count"'}' "$output_file")
right_centroid=$(echo "$spectral_stats" | grep "centroid" "$output_file" | awk -F"=" '{sum += $2} END {print sum/'"$frame_count"'}' "$output_file")

echo "Left channel centroid: "$left_centroid" and right channel centroid: "$right_centroid" with "$frame_count" number of frames."