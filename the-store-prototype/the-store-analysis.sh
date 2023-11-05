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

        centroid_1=(0)
        centroid_2=(0)
        centroid_3=(0)
        centroid_4=(0)
        centroid_5=(0)
        centroid_6=(0)
        centroid_7=(0)
        centroid_8=(0)
        # parses spectral centroid value from up to 8 channels and returns the mean value
        centroid_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {print ", "$2}' "$output_file")
        centroid_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.centroid/ {print ", "$2}' "$output_file")
        centroid_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.centroid/ {print ", "$2}' "$output_file")
        centroid_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.centroid/ {print ", "$2}' "$output_file")
        centroid_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.centroid/ {print ", "$2}' "$output_file")
        centroid_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.centroid/ {print ", "$2}' "$output_file")
        centroid_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.centroid/ {print ", "$2}' "$output_file")
        centroid_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.centroid/ {print ", "$2}' "$output_file")

        variance_1=(0)
        variance_2=(0)
        variance_3=(0)
        variance_4=(0)
        variance_5=(0)
        variance_6=(0)
        variance_7=(0)
        variance_8=(0)
        # parses variance value from up to 8 channels and returns the mean value
        variance_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.variance/ {print ", "$2*750000}' "$output_file")
        variance_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.variance/ {print ", "$2*750000}' "$output_file")
        variance_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.variance/ {print ", "$2*750000}' "$output_file")
        variance_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.variance/ {print ", "$2*750000}' "$output_file")
        variance_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.variance/ {print ", "$2*750000}' "$output_file")
        variance_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.variance/ {print ", "$2*750000}' "$output_file")
        variance_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.variance/ {print ", "$2*750000}' "$output_file")
        variance_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.variance/ {print ", "$2*750000}' "$output_file")

        spread_1=(0)
        spread_2=(0)
        spread_3=(0)
        spread_4=(0)
        spread_5=(0)
        spread_6=(0)
        spread_7=(0)
        spread_8=(0)
        # parses spread value from up to 8 channels and returns the mean value
        spread_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {print ", "$2}' "$output_file")
        spread_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.spread/ {print ", "$2}' "$output_file")
        spread_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.spread/ {print ", "$2}' "$output_file")
        spread_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.spread/ {print ", "$2}' "$output_file")
        spread_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.spread/ {print ", "$2}' "$output_file")
        spread_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.spread/ {print ", "$2}' "$output_file")
        spread_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.spread/ {print ", "$2}' "$output_file")
        spread_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.spread/ {print ", "$2}' "$output_file")

        skewness_1=(0)
        skewness_2=(0)
        skewness_3=(0)
        skewness_4=(0)
        skewness_5=(0)
        skewness_6=(0)
        skewness_7=(0)
        skewness_8=(0)
        # parses skewness value from up to 8 channels and returns the mean value
        skewness_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {print ", "$2}' "$output_file")
        skewness_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.skewness/ {print ", "$2}' "$output_file")
        skewness_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.skewness/ {print ", "$2}' "$output_file")
        skewness_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.skewness/ {print ", "$2}' "$output_file")
        skewness_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.skewness/ {print ", "$2}' "$output_file")
        skewness_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.skewness/ {print ", "$2}' "$output_file")
        skewness_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.skewness/ {print ", "$2}' "$output_file")
        skewness_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.skewness/ {print ", "$2}' "$output_file")

        kurtosis_1=(0)
        kurtosis_2=(0)
        kurtosis_3=(0)
        kurtosis_4=(0)
        kurtosis_5=(0)
        kurtosis_6=(0)
        kurtosis_7=(0)
        kurtosis_8=(0)
        # parses kurtosis value from up to 8 channels and returns the mean value
        kurtosis_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.kurtosis/ {print ", "$2}' "$output_file")
        kurtosis_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.kurtosis/ {print ", "$2}' "$output_file")

        entropy_1=(0)
        entropy_2=(0)
        entropy_3=(0)
        entropy_4=(0)
        entropy_5=(0)
        entropy_6=(0)
        entropy_7=(0)
        entropy_8=(0)
        # parses entropy value from up to 8 channels and returns the mean value
        entropy_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {print ", "$2}' "$output_file")
        entropy_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.entropy/ {print ", "$2}' "$output_file")
        entropy_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.entropy/ {print ", "$2}' "$output_file")
        entropy_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.entropy/ {print ", "$2}' "$output_file")
        entropy_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.entropy/ {print ", "$2}' "$output_file")
        entropy_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.entropy/ {print ", "$2}' "$output_file")
        entropy_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.entropy/ {print ", "$2}' "$output_file")
        entropy_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.entropy/ {print ", "$2}' "$output_file")

        flatness_1=(0)
        flatness_2=(0)
        flatness_3=(0)
        flatness_4=(0)
        flatness_5=(0)
        flatness_6=(0)
        flatness_7=(0)
        flatness_8=(0)
        # parses flatness value from up to 8 channels and returns the mean value
        flatness_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {print ", "$2}' "$output_file")
        flatness_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.flatness/ {print ", "$2}' "$output_file")
        flatness_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.flatness/ {print ", "$2}' "$output_file")
        flatness_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.flatness/ {print ", "$2}' "$output_file")
        flatness_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.flatness/ {print ", "$2}' "$output_file")
        flatness_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.flatness/ {print ", "$2}' "$output_file")
        flatness_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.flatness/ {print ", "$2}' "$output_file")
        flatness_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.flatness/ {print ", "$2}' "$output_file")

        crest_1=(0)
        crest_2=(0)
        crest_3=(0)
        crest_4=(0)
        crest_5=(0)
        crest_6=(0)
        crest_7=(0)
        crest_8=(0)
        # parses crest value from up to 8 channels and returns the mean value
        crest_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {print ", "$2}' "$output_file")
        crest_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.crest/ {print ", "$2}' "$output_file")
        crest_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.crest/ {print ", "$2}' "$output_file")
        crest_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.crest/ {print ", "$2}' "$output_file")
        crest_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.crest/ {print ", "$2}' "$output_file")
        crest_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.crest/ {print ", "$2}' "$output_file")
        crest_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.crest/ {print ", "$2}' "$output_file")
        crest_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.crest/ {print ", "$2}' "$output_file")

        flux_1=(0)
        flux_2=(0)
        flux_3=(0)
        flux_4=(0)
        flux_5=(0)
        flux_6=(0)
        flux_7=(0)
        flux_8=(0)
        # parses flux value from up to 8 channels and returns the mean value
        flux_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {print ", "$2}' "$output_file")
        flux_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.flux/ {print ", "$2}' "$output_file")
        flux_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.flux/ {print ", "$2}' "$output_file")
        flux_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.flux/ {print ", "$2}' "$output_file")
        flux_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.flux/ {print ", "$2}' "$output_file")
        flux_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.flux/ {print ", "$2}' "$output_file")
        flux_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.flux/ {print ", "$2}' "$output_file")
        flux_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.flux/ {print ", "$2}' "$output_file")

        slope_1=(0)
        slope_2=(0)
        slope_3=(0)
        slope_4=(0)
        slope_5=(0)
        slope_6=(0)
        slope_7=(0)
        slope_8=(0)
        # parses slope value from up to 8 channels and returns the mean value
        slope_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {print ", "$2}' "$output_file")
        slope_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.slope/ {print ", "$2}' "$output_file")
        slope_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.slope/ {print ", "$2}' "$output_file")
        slope_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.slope/ {print ", "$2}' "$output_file")
        slope_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.slope/ {print ", "$2}' "$output_file")
        slope_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.slope/ {print ", "$2}' "$output_file")
        slope_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.slope/ {print ", "$2}' "$output_file")
        slope_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.slope/ {print ", "$2}' "$output_file")

        decrease_1=(0)
        decrease_2=(0)
        decrease_3=(0)
        decrease_4=(0)
        decrease_5=(0)
        decrease_6=(0)
        decrease_7=(0)
        decrease_8=(0)
        # parses decrease value from up to 8 channels and returns the mean value
        decrease_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.decrease/ {print ", "$2}' "$output_file")
        decrease_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.decrease/ {print ", "$2}' "$output_file")
        decrease_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.decrease/ {print ", "$2}' "$output_file")
        decrease_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.decrease/ {print ", "$2}' "$output_file")
        decrease_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.decrease/ {print ", "$2}' "$output_file")
        decrease_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.decrease/ {print ", "$2}' "$output_file")
        decrease_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.decrease/ {print ", "$2}' "$output_file")
        decrease_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.decrease/ {print ", "$2}' "$output_file")

        rolloff_1=(0)
        rolloff_2=(0)
        rolloff_3=(0)
        rolloff_4=(0)
        rolloff_5=(0)
        rolloff_6=(0)
        rolloff_7=(0)
        rolloff_8=(0)
        # parses rolloff value from up to 8 channels and returns the mean value
        rolloff_1["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {print ", "$2}' "$output_file")
        rolloff_2["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/2.rolloff/ {print ", "$2}' "$output_file")
        rolloff_3["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/3.rolloff/ {print ", "$2}' "$output_file")
        rolloff_4["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/4.rolloff/ {print ", "$2}' "$output_file")
        rolloff_5["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/5.rolloff/ {print ", "$2}' "$output_file")
        rolloff_6["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/6.rolloff/ {print ", "$2}' "$output_file")
        rolloff_7["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/7.rolloff/ {print ", "$2}' "$output_file")
        rolloff_8["$frame_count"]=$(echo "$spectral_stats" | awk -F"=" '/8.rolloff/ {print ", "$2}' "$output_file")

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
            "ch1": ['"${centroid_1[@]%,}"'],
            "ch2": ['"${centroid_2[@]%,}"'],
            "ch3": ['"${centroid_3[@]%,}"'],
            "ch4": ['"${centroid_4[@]%,}"'],
            "ch5": ['"${centroid_5[@]%,}"'],
            "ch6": ['"${centroid_6[@]%,}"'],
            "ch7": ['"${centroid_7[@]%,}"'],
            "ch8": ['"${centroid_8[@]%,}"']
        },
        "variance": {
            "ch1": ['"${variance_1[@]%,}"'],
            "ch2": ['"${variance_2[@]%,}"'],
            "ch3": ['"${variance_3[@]%,}"'],
            "ch4": ['"${variance_4[@]%,}"'],
            "ch5": ['"${variance_5[@]%,}"'],
            "ch6": ['"${variance_6[@]%,}"'],
            "ch7": ['"${variance_7[@]%,}"'],
            "ch8": ['"${variance_8[@]%,}"']
        },
        "spread": {
            "ch1": ['"${spread_1[@]%,}"'],
            "ch2": ['"${spread_2[@]%,}"'],
            "ch3": ['"${spread_3[@]%,}"'],
            "ch4": ['"${spread_4[@]%,}"'],
            "ch5": ['"${spread_5[@]%,}"'],
            "ch6": ['"${spread_6[@]%,}"'],
            "ch7": ['"${spread_7[@]%,}"'],
            "ch8": ['"${spread_8[@]%,}"']
        },
        "skewness": {
            "ch1": ['"${skewness_1[@]%,}"'],
            "ch2": ['"${skewness_2[@]%,}"'],
            "ch3": ['"${skewness_3[@]%,}"'],
            "ch4": ['"${skewness_4[@]%,}"'],
            "ch5": ['"${skewness_5[@]%,}"'],
            "ch6": ['"${skewness_6[@]%,}"'],
            "ch7": ['"${skewness_7[@]%,}"'],
            "ch8": ['"${skewness_8[@]%,}"']
        },
        "kurtosis": {
            "ch1": ['"${kurtosis_1[@]%,}"'],
            "ch2": ['"${kurtosis_2[@]%,}"'],
            "ch3": ['"${kurtosis_3[@]%,}"'],
            "ch4": ['"${kurtosis_4[@]%,}"'],
            "ch5": ['"${kurtosis_4[@]%,}"'],
            "ch6": ['"${kurtosis_5[@]%,}"'],
            "ch7": ['"${kurtosis_6[@]%,}"'],
            "ch8": ['"${kurtosis_7[@]%,}"']
        },
        "entropy": {
            "ch1": ['"${entropy_1[@]%,}"'],
            "ch2": ['"${entropy_2[@]%,}"'],
            "ch3": ['"${entropy_3[@]%,}"'],
            "ch4": ['"${entropy_4[@]%,}"'],
            "ch5": ['"${entropy_5[@]%,}"'],
            "ch6": ['"${entropy_6[@]%,}"'],
            "ch7": ['"${entropy_7[@]%,}"'],
            "ch8": ['"${entropy_8[@]%,}"']
        },
        "flatness": {
            "ch1": ['"${flatness_1[@]%,}"'],
            "ch2": ['"${flatness_2[@]%,}"'],
            "ch3": ['"${flatness_3[@]%,}"'],
            "ch4": ['"${flatness_4[@]%,}"'],
            "ch5": ['"${flatness_5[@]%,}"'],
            "ch6": ['"${flatness_6[@]%,}"'],
            "ch7": ['"${flatness_7[@]%,}"'],
            "ch8": ['"${flatness_8[@]%,}"']
        },
        "crest": {
            "ch1": ['"${crest_1[@]%,}"'],
            "ch2": ['"${crest_2[@]%,}"'],
            "ch3": ['"${crest_3[@]%,}"'],
            "ch4": ['"${crest_4[@]%,}"'],
            "ch5": ['"${crest_5[@]%,}"'],
            "ch6": ['"${crest_6[@]%,}"'],
            "ch7": ['"${crest_7[@]%,}"'],
            "ch8": ['"${crest_8[@]%,}"']
        },
        "flux": {
            "ch1": ['"${flux_1[@]%,}"'],
            "ch2": ['"${flux_2[@]%,}"'],
            "ch3": ['"${flux_3[@]%,}"'],
            "ch4": ['"${flux_4[@]%,}"'],
            "ch5": ['"${flux_5[@]%,}"'],
            "ch6": ['"${flux_6[@]%,}"'],
            "ch7": ['"${flux_7[@]%,}"'],
            "ch8": ['"${flux_8[@]%,}"']
        },
        "slope": {
            "ch1": ['"${slope_1[@]%,}"'],
            "ch2": ['"${slope_2[@]%,}"'],
            "ch3": ['"${slope_3[@]%,}"'],
            "ch4": ['"${slope_4[@]%,}"'],
            "ch5": ['"${slope_5[@]%,}"'],
            "ch6": ['"${slope_6[@]%,}"'],
            "ch7": ['"${slope_7[@]%,}"'],
            "ch8": ['"${slope_8[@]%,}"']
        },
        "decrease": {
            "ch1": ['"${decrease_1[@]%,}"'],
            "ch2": ['"${decrease_2[@]%,}"'],
            "ch3": ['"${decrease_3[@]%,}"'],
            "ch4": ['"${decrease_4[@]%,}"'],
            "ch5": ['"${decrease_5[@]%,}"'],
            "ch6": ['"${decrease_6[@]%,}"'],
            "ch7": ['"${decrease_7[@]%,}"'],
            "ch8": ['"${decrease_8[@]%,}"']
        },
        "rolloff": {
            "ch1": ['"${rolloff_1[@]%,}"'],
            "ch2": ['"${rolloff_2[@]%,}"'],
            "ch3": ['"${rolloff_3[@]%,}"'],
            "ch4": ['"${rolloff_4[@]%,}"'],
            "ch5": ['"${rolloff_5[@]%,}"'],
            "ch6": ['"${rolloff_6[@]%,}"'],
            "ch7": ['"${rolloff_7[@]%,}"'],
            "ch8": ['"${rolloff_8[@]%,}"']
        },
    "frame_count": '"$frame_count"'
    }
}' > ."$filename".json
    fi
done
shopt -u nocaseglob

rm "$output_file"