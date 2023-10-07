# the-store
Information retrieval system for audio personal information management

## Files Inside
Description of files:
1. astats_raw.sh - returns all raw astats data.
2. aspectralstats_raw.sh - returns all raw aspectralstats data.
3. aspectralstats_to_txt.sh - returns all spectralstats data and writes to .txt file.
4. aspectralstats_mean_centroid - returns all aspectralstats data and calculates mean for spectral centroid (in JSON).
5. aspectralstats_mean_all - returns all aspectralstats data and calculates mean for all metrics (in JSON).
6. stream_aspectralstats_mean_all.sh - returns all metadata and aspectralstats data and calculates mean for all metrics (in JSON).
7. r128_stream_aspectralstats_mean_all.sh - returns all loudness data, metadata, aspectralstats data and calculates mean for all metrics (in JSON).

## To Run
Number 7 is the most complete, so start there. The others are just other smaller chunks I made while learning more about ffmpeg. They do slightly different things, but also significantly less. To run, navigate to the directory with audio files (any format should work) using 'cd' and run the script from the terminal.

## Some notes
1. The JSON file is kind of clunky. ffprobe can't do analysis on its own and needs to be coupled with ffmpeg in some instances. Because of this, the output for the spectral analysis is formatted as a JSON object after analysis and appended to the JSON object formatted by ffprobe, which includes the metadata. The other, more important reason for why it's formatted like this is because the aspectralstats analysis outputs a value for each metric every frame. The script (#7) finds the mean value of each metric using the raw ffmpeg output and then formats it as a JSON object afterwards. It seemed easier than to try to format first, then calculate the mean, then reassemble in JSON. Perhaps there is another way? However, it may not be a problem at all with a few tweaks.
2. Altogether the analysis and writing the JSON file takes a bit longer than expected, although it's still pretty quick. You can change the window size for the analysis using the 'win_size' key found at the top of each script script where available. The number needs to be a power of two and can range from 32 to 65536.
