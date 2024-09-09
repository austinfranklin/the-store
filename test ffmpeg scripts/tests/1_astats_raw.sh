# writes astats data to .txt file on desktop - WORKS BUT DOESN'T OUTPUT IN JSON
output_file=~/Desktop/astats.txt

for file in *.*; do
    ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -filter:a astats=metadata=1:measure_overall=1,ametadata=print:key=lavfi.astats.Overall.all:file=- -f null - 2>> "$output_file"
done