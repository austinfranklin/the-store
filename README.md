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
