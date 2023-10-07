# writes aspectralstats data to .txt file on desktop - WORKS BUT OUTPUTS VALUE EVERY FRAME!
file="input.wav"

output_file="$HOME/Desktop/aspectralstats.txt"

ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -af aspectralstats=measure=centroid:win_size=2048,ametadata=print:file=- -f null - > "$output_file"