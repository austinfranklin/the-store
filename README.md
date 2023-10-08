# the-store
Information retrieval system for audio personal information management

## Files Inside
Description of files:
1. Returns all raw astats data (output in terminal).
2. Returns all raw aspectralstats data (output in terminal).
3. Returns all spectralstats data and writes to .txt file (ffmpeg default format).
4. Returns all aspectralstats data and calculates mean for spectral centroid (outputs in JSON).
5. Returns all aspectralstats data and calculates mean for all metrics (in JSON).
6. Returns all metadata and aspectralstats data and calculates mean for all metrics (outputs in JSON).
7. Returns all loudness data, metadata, aspectralstats data and calculates mean for all metrics (outputs in JSON).

## To Run
Number 7 is the most complete, so start there. The others are shorter scripts I made while I was testing ffmpeg and ffprobe. They do slightly different things, but significantly less. To run, navigate to the directory with audio files (any format should work) using 'cd' and run the script from the terminal. Some of them don't read through an entire folder, so the file name will needed to added manually.

## Some notes
1. The JSON file is kind of clunky. FFprobe can't do analysis on its own and needs to be coupled with FFmpeg in some instances. Because of this, the output for the spectral analysis is formatted as a JSON object after analysis and appended to the JSON object including the metadata formatted by FFprobe. The other, more important reason for why it's formatted like this is because aspectralstats analysis outputs a value for each metric every frame. The script (#7) finds the mean value of each metric using the default FFmpeg output and then formats it as a JSON object after all frames have been output. It seemed easier than to try to format first, then calculate the mean, then reassemble in JSON.
2. You can change the window size for the analysis using the 'win_size' key found at the top of each script script where available and play around with calculation and output time. The number needs to be a power of two and can range from 32 to 65536.
3. Aspectralstats won't work without the latest version of ffmpeg and its libraries:

    FFmpeg 6.0
    libavutil      58. 27.100 / 58. 27.100
    libavcodec     60. 30.101 / 60. 30.101
    libavformat    60. 15.100 / 60. 15.100
    libavdevice    60.  2.101 / 60.  2.101
    libavfilter     9. 11.100 /  9. 11.100
    libswscale      7.  4.100 /  7.  4.100
    libswresample   4. 11.100 /  4. 11.100
    libpostproc    57.  2.100 / 57.  2.100
