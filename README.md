# the-store
Information retrieval system for personal information management of audio files

FFmpeg source code here: https://github.com/FFmpeg/FFmpeg

## Files Inside
Description of files:
1. Tests - various assortments of tests that do small things.
2. Multichannel - retireves all data for audio files up to 8 channels
3. Similarity_measure - finds the absolute value difference between keys in json files

## To Run General
To run, navigate to the directory with audio files (any format should work) using 'cd' and run the script from the terminal. Some of test scripts don't read through an entire folder, so the file name will needed to added manually in those cases.

## To Run Similarity_measure
Add audio files to this folder, navigate to this folder in terminal with 'cd' and run '10_for_similarity.sh' script. All files will have a dedicated .json file created. To run the 'similar_auto.sh' script, run that file the same directory specifying the keys you want measured using the -k flag.

For instance:

bash similar_auto.sh -k *key1* -k *key2* -k *etc.*

To run the 'similar_man.sh', you need to manually specify the .json files you want to measure. For instance:

bash similar_man.sh *file1.json file2.json etc.* -k *key1* -k *key2* -k *etc.*

You need to delete the .json files created for non-audio files otherwise you'll get an error. The intended data will still show in the terminal but will be hard to navigate. I'm still working on this.

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
1. Add ignore to file formats that aren't audio files in analysis scripts so the script doesn't throw error or write files unnecessarily
2. add similar_auto.sh script to analysis script so that this process happens automatically and finds similarity for all metrics
3. Write the similarity measures to .txt file so it be can be read more easily... and parsed eventually.
4. Possibly hide .json files during analyis
5. Start coding on the store, both as library based on ffmpeg and its connection to prototypical ui:s
