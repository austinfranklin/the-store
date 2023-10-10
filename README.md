# the-store
Information retrieval system for personal information management of audio files

FFmpeg source code here: https://github.com/FFmpeg/FFmpeg

## To Run searching_the_store
1. Run the analysis.sh script inside a folder
2. Then run the search.sh like:

bash search.sh *<file.wav>* *<key>*

If file name has spaces, enclose it like "My File.wav". You can rerun this script over and over with new keys to see how they rank. The output in the terminal should look something like this:

333.29 .CelloA.wav.json vs .CelloG.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3653.83 (File2),  
366.95 .CelloA.wav.json vs .CelloD.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3620.17 (File2),  
838.95 .CelloA.wav.json vs .CelloE.wav.json: spectral.centroid.ch1: 3987.12 (File1), 3148.17 (File2),  
936.8 .CelloC.wav.json vs .CelloA.wav.json: spectral.centroid.ch1: 3050.32 (File1), 3987.12 (File2),

The number on the far left is the absolute difference between two files. The following string is the two file names (one of of which you specify as an argument when running the script), and finally, the two individual values for the files 1 and 2 are displayed so you can check the difference on the left yourself. The absolute differences on the left should be sorted from smallest to largest. In the example above, the spectral centroid for CelloG.wav is closer to CelloA.wav than CelloC.wav by about 600Hz!

Warning: all the files generated are hidded, so cmd+shift+. if you want to see them. Should work with any sudio file format...

### Keys
You can open the hidden .json files and find keys you want to use, or use the following shortened list. You need to enter the entire nested key in order for it to work:

metadata.format.duration (seconds)  
metadata.format.size (bytes)  
metadata.format.bit_rate  
loudness.max_volume (dB)  
loudness.mean_volume (dB)  
loudness.integrated_lufs (dB)  
loudness.threshold (dB)  
loudness.lra (dB)  
spectral.centroid.ch1 (Hz)  
spectral.centroid.ch2 (Hz)  
spectral.variance.ch1 (Hz)  
spectral.variance.ch2 (Hz)  

(most output frequency in Hz)  
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


## Some notes
1. FFprobe can't do analysis on its own and needs to be coupled with FFmpeg. Because of this, the output for the spectral analysis is formatted as a JSON object after analysis and appended to the JSON object including the metadata formatted by FFprobe. The other, more important reason for why it's formatted like this is because aspectralstats analysis outputs a value for each key every frame. The script (#9) finds the mean value of each key using the default FFmpeg output and then formats it as a JSON object after all frames have been output. It seemed easier than to try to format first, then calculate the mean, then reassemble in JSON.
2. You can change the window size for the analysis using the 'win_size' key found at the top of each script where available and play around with calculation time. The number needs to be a power of two and can range from 32 to 65536.
3. For the scripts that read through folders, reanalyzing a folder will append all new data to the same .json file. This will return an error when the newly created .json file is read. You can ignore this error for now.
4. Aspectralstats won't work without the latest version of ffmpeg and its libraries:

    FFmpeg 6.0
    libavutil      58. 27.100 / 58. 27.100
    libavcodec     60. 30.101 / 60. 30.101
    libavformat    60. 15.100 / 60. 15.100
    libavdevice    60.  2.101 / 60.  2.101
    libavfilter     9. 11.100 /  9. 11.100
    libswscale      7.  4.100 /  7.  4.100
    libswresample   4. 11.100 /  4. 11.100
    libpostproc    57.  2.100 / 57.  2.100

## Still want to do
Depending on what our next steps are, I would like to do the following:
5. Start coding on the store, both as library based on ffmpeg and its connection to prototypical ui:s
