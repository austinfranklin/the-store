#!/bin/bash

# finds metadata AND spectral data AND loudness data - outputs in JSON format - JSON is kind of ugly
output_file=".ffmpeg_data.txt"

path=$1


# shopt turn case insensitivity ON
shopt -s nocaseglob
shopt -s nullglob
for file in $path*.{wav,mp3,aiff,aif,m4a,flac,ogg}; do
    filename="$file"

    if [ -e ".$filename.json" ]; then
        echo "$filename"" already analyzed"
    else
        # main command - analysis done here
        meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
        spectral_stats=$(ffmpeg -hide_banner -i "$file" -af aspectralstats=measure=all:win_size=65536,ametadata=print:file=- -f null - > "$output_file")
        lufs_stats=$(ffmpeg -hide_banner -i "$file" -af ebur128=framelog=verbose -f null - 2>> "$output_file")
        volume_stats=$(ffmpeg -hide_banner -i "$file" -filter:a volumedetect -f null - 2>> "$output_file")

        # parses frame number from data - needed to adapt to any file length
        frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

        # parses overall lufs stats
        integrated=$(echo "$lufs_stats" | awk '/I:/ {print $2}' "$output_file")
        #threshold=$(echo "$lufs_stats" | awk '/Threshold:/ {print $2}' "$output_file")
        lra=$(echo "$lufs_stats" | awk '/LRA:/ {print $2}' "$output_file")

        # parses volume stats
        mean_volume=$(echo "$volume_stats" | awk '/mean_volume:/ {print $5}' "$output_file")
        max_volume=$(echo "$volume_stats" | awk '/max_volume:/ {print $5}' "$output_file")

        centroid_1=()
        centroid_2=()
        # parses spectral centroid value from up to 8 channels and returns the mean value
        centroid_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {print $2","}' "$output_file")
        centroid_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.centroid/ {print $2","}' "$output_file")

        # gets the centroid mean value
        centroid_mean=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {centroid_1 += $2} END {print centroid_1/'"$frame_count"'}' "$output_file")

        spread_1=()
        spread_2=()
        # parses spread value from up to 8 channels and returns the mean value
        spread_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {print $2","}' "$output_file")
        spread_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.spread/ {print $2","}' "$output_file")
        # gets the spread mean value
        spread_mean=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {spread_1 += $2} END {print spread_1/'"$frame_count"'}' "$output_file")

        skewness_1=()
        skewness_2=()
        # parses skewness value from up to 8 channels and returns the mean value
        skewness_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {print $2","}' "$output_file")
        skewness_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.skewness/ {print $2","}' "$output_file")
        # gets the skewness mean value
        skewness_mean=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {skewness_1 += $2} END {print skewness_1/'"$frame_count"'}' "$output_file")

        kurtosis_1=()
        kurtosis_2=()
        # parses kurtosis value from up to 8 channels and returns the mean value
        kurtosis_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {print $2","}' "$output_file")
        kurtosis_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.kurtosis/ {print $2","}' "$output_file")
        # gets the kurtosis mean value
        kurtosis_mean=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {kurtosis_1 += $2} END {print kurtosis_1/'"$frame_count"'}' "$output_file")

        entropy_1=()
        entropy_2=()
        # parses entropy value from up to 8 channels and returns the mean value
        entropy_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {print $2","}' "$output_file")
        entropy_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.entropy/ {print $2","}' "$output_file")
        # gets the entropy mean value
        entropy_mean=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {entropy_1 += $2} END {print entropy_1/'"$frame_count"'}' "$output_file")

        flatness_1=()
        flatness_2=()
        # parses flatness value from up to 8 channels and returns the mean value
        flatness_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {print $2","}' "$output_file")
        flatness_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.flatness/ {print $2","}' "$output_file")
        # gets the flatness mean value
        flatness_mean=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {flatness_1 += $2} END {print flatness_1/'"$frame_count"'}' "$output_file")

        crest_1=()
        crest_2=()
        # parses crest value from up to 8 channels and returns the mean value
        crest_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {print $2","}' "$output_file")
        crest_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.crest/ {print $2","}' "$output_file")
        # gets the crest mean value
        crest_mean=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {crest_1 += $2} END {print crest_1/'"$frame_count"'}' "$output_file")

        flux_1=()
        flux_2=()
        # parses flux value from up to 8 channels and returns the mean value
        flux_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {print $2","}' "$output_file")
        flux_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.flux/ {print $2","}' "$output_file")
        # gets the flux mean value
        flux_mean=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {flux_1 += $2} END {print flux_1/'"$frame_count"'}' "$output_file")

        slope_1=()
        slope_2=()
        # parses slope value from up to 8 channels and returns the mean value
        slope_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {print $2","}' "$output_file")
        slope_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.slope/ {print $2","}' "$output_file")
        # gets the slope mean value
        slope_mean=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {slope_1 += $2} END {print slope_1/'"$frame_count"'}' "$output_file")

        rolloff_1=()
        rolloff_2=()
        # parses rolloff value from up to 8 channels and returns the mean value
        rolloff_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {print $2","}' "$output_file")
        rolloff_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.rolloff/ {print $2","}' "$output_file")
        # gets the rolloff mean value
        rolloff_mean=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {rolloff_1 += $2} END {print rolloff_1/'"$frame_count"'}' "$output_file")

        echo '
{
    "metadata": '"$meta_stats"',
    "loudness": {
        "max_volume": '"$max_volume"',
        "mean_volume": '"$mean_volume"',
        "integrated_lufs": '"$integrated"',
        "lra": '"$lra"'
    },
    "spectral": {
        "centroid": {
            "mean": '"$centroid_mean"',
            "ch1": ['"${centroid_1[@]%,}"'],
            "ch2": ['"${centroid_2[@]%,}"']
        },
        "spread": {
            "mean": '"$spread_mean"',
            "ch1": ['"${spread_1[@]%,}"'],
            "ch2": ['"${spread_2[@]%,}"']
        },
        "skewness": {
            "mean": '"$skewness_mean"',
            "ch1": ['"${skewness_1[@]%,}"'],
            "ch2": ['"${skewness_2[@]%,}"']
        },
        "kurtosis": {
            "mean": '"$kurtosis_mean"',
            "ch1": ['"${kurtosis_1[@]%,}"'],
            "ch2": ['"${kurtosis_2[@]%,}"']
        },
        "entropy": {
            "mean": '"$entropy_mean"',
            "ch1": ['"${entropy_1[@]%,}"'],
            "ch2": ['"${entropy_2[@]%,}"']
        },
        "flatness": {
            "mean": '"$flatness_mean"',
            "ch1": ['"${flatness_1[@]%,}"'],
            "ch2": ['"${flatness_2[@]%,}"']
        },
        "crest": {
            "mean": '"$crest_mean"',
            "ch1": ['"${crest_1[@]%,}"'],
            "ch2": ['"${crest_2[@]%,}"']
        },
        "flux": {
            "mean": '"$flux_mean"',
            "ch1": ['"${flux_1[@]%,}"'],
            "ch2": ['"${flux_2[@]%,}"']
        },
        "slope": {
            "mean": '"$slope_mean"',
            "ch1": ['"${slope_1[@]%,}"'],
            "ch2": ['"${slope_2[@]%,}"']
        },
        "rolloff": {
            "mean": '"$rolloff_mean"',
            "ch1": ['"${rolloff_1[@]%,}"'],
            "ch2": ['"${rolloff_2[@]%,}"']
        },
    "frame_count": '"$frame_count"'
    }
}' > ."$filename".json
    fi
done
shopt -u nocaseglob

rm "$output_file"