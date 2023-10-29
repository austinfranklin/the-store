# the-store
Information retrieval system for personal information management of audio files

FFmpeg source code here: https://github.com/FFmpeg/FFmpeg

# To Run temporal_plotting
1. Run the time-analysis.sh script inside a folder
2. Enjoy

# To Run graph_plotting
1. Run the analysis.sh script inside a folder
2. Then run plot.sh like:

bash plot.sh *type* *argument*

The type is either 'file' or 'feature' and the argument is the name of the audio file or feature from the list of keys below. You may need to move a hidden '.graph.sh' file into the folder you want to analyze and plot if you use one other than the one included in the repo. You can move additional audio files into that folder however.

The plot.sh script will build the .png files in the audio_files directory.

# To Run sort_and_sim
1. Run the analysis.sh script inside a folder
2. Then run sort.sh like:

bash sort.sh *file.wav* *key_name*

If file name has spaces, enclose it like "My File.wav". You can rerun this script over and over with new keys to see how they rank. The output in the terminal should look something like this:

333.29 .CelloA.wav.json vs .CelloG.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3653.83 (File2),  
366.95 .CelloA.wav.json vs .CelloD.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3620.17 (File2),  
838.95 .CelloA.wav.json vs .CelloE.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3148.17 (File2),  
936.8 .CelloC.wav.json vs .CelloA.wav.json: spectral.centroid.ch1: 3050.32 (File1), 3987.12 (File2),

The number on the far left is the absolute difference between two files. The following string is the two file names (one of of which you specify as an argument when running the script), and finally, the two individual values for the files 1 and 2 are displayed so you can check the difference on the left yourself. The absolute differences on the left should be sorted from smallest to largest. In the example above, the spectral centroid for CelloG.wav is closer to CelloA.wav than CelloC.wav by about 600Hz!

If you want, you can also run it without the file name argument, like:

bash sort.sh *key_name*

This will return all audio files and values for that key from smallest to largest. No need to specify a file name to use for comparison. This output will look something like this:

4.545215 .discordant-voices.wav.json  metadata.format.duration  
7.411905 .deep-bass-rumble-2.wav.json  metadata.format.duration  
15.212562 .reverbbells.wav.json  metadata.format.duration  
17.096803 .voices.wav.json  metadata.format.duration  
18.857800 .deep-bass-rumble.wav.json  metadata.format.duration  
24.752472 .crescendo.wav.json  metadata.format.duration  

The number on the left is the value, then the file, then the key name.

Warning: all the generated .json and .txt files are hidded, so press cmd+shift+. if you want to see them. Should work with any audio file format...

# Keys
You can open the hidden .json files and find more keys if you want, or you can use the following shortened list. You need to enter the entire nested key in order for it to work:

metadata.format.duration (seconds)  
loudness.max_volume (dB)  
loudness.mean_volume (dB)  
loudness.integrated_lufs (dB)  
loudness.threshold (dB)  
loudness.lra (dB)  

(most output frequency in Hz)  
spectral.centroid.ch1 (Hz)  
spectral.centroid.ch2 (Hz)  
spectral.variance.ch1 (Hz)  
spectral.variance.ch2 (Hz)  
spectral.spread.ch1  
spectral.spread.ch2  
spectral.skewness.ch1  
spectral.skewness.ch2  
spectral.kurtosis.ch1  
spectral.kurtosis.ch2  
spectral.entropy.ch1  
spectral.entropy.ch2  
spectral.flatness.ch1  
spectral.flatness.ch2  
spectral.crest.ch1  
spectral.crest.ch2  
spectral.flux.ch1  
spectral.flux.ch2  
spectral.slope.ch1  
spectral.slope.ch2  
spectral.decrease.ch1  
spectral.decrease.ch2  
spectral.rolloff.ch1  
spectral.rolloff.ch2  

# Some notes
1. You can change the window size for the analysis using the 'win_size' key found at the top of each script where available and play around with calculation time. The number needs to be a power of two and can range from 32 to 65536.
2. Aspectralstats won't work without the latest version of ffmpeg and its libraries:

    FFmpeg 6.0
    libavutil      58. 27.100 / 58. 27.100
    libavcodec     60. 30.101 / 60. 30.101
    libavformat    60. 15.100 / 60. 15.100
    libavdevice    60.  2.101 / 60.  2.101
    libavfilter     9. 11.100 /  9. 11.100
    libswscale      7.  4.100 /  7.  4.100
    libswresample   4. 11.100 /  4. 11.100
    libpostproc    57.  2.100 / 57.  2.100

# To Do
1. Make script that generates PNGs of all normalized features for a given audio file AND all files with respect to one feature. Done, but still needs:
       - [x] to set file or feature name in the key and title of plot.
       - [x] rescale values so they appear more distinct. *Could be better.*
       - [x] make generally cleaner.
3. Determine how to segment an audio file to retrieve temporal data for features (possibly is 3-5 second chunks). How should we compare these chunks?
4. Determine which features have perceptual correlations.
       - [x] Centroid
       - [ ] Variance
       - [ ] Spread
       - [ ] Skewness
       - [ ] Kurtosis
       - [ ] Entropy
       - [x] Flatness
       - [ ] Crest
       - [ ] flux
       - [ ] Slope
       - [ ] Decrease
       - [ ] Rolloff
       - [x] metadata.format.duration
       - [x] loudness.max_volume
       - [ ] loudness.mean_volume
       - [x] loudness.integrated_lufs
       - [ ] loudness.threshold
       - [ ] loudness.lra
6. Figure out how to plot multiple files and feature within the same graph.

## Ideas
1. For measuring similarity we could use a classification algorithm that returns the probability that two files are related based on all features. The files could then be sorted based on how high the probability is that two files are similar. We could use a one-to-one comparison of chunks of audio files or a dynamic time warping algorithm. Not sure if it even matters since the length of time our ears need to determine similarity is likely long enough to warrant a cruder one-to-one comparison.
2. For visualizing all data and all files, we could plot a 3D vector space. We have FFmpeg measuring the spectral content in Hz, loudness in dB, and other spectral metrics in normalized floating point values. It would be really cool visually to map each dimension (x, y, z) to frequency, loudness, and something else to create a perceptual 3D space. Furthermore, if you were able to click on each node in the space and play that file, it would be easy to browse.
