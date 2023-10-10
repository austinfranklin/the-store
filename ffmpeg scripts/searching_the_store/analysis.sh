#!/bin/bash

# finds metadata AND spectral data AND loudness data - outputs in JSON format - JSON is kind of ugly
output_file=".ffmpeg_data.txt"

for file in *.*; do
    # main command - analysis done here
    meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
    spectral_stats=$(ffmpeg -i "$file" -af aspectralstats=measure=all:win_size=65536,ametadata=print:file=- -f null - > "$output_file")
    lufs_stats=$(ffmpeg -i "$file" -af ebur128=framelog=verbose -f null - 2>> "$output_file")
    volume_stats=$(ffmpeg -i "$file" -filter:a volumedetect -f null - 2>> "$output_file")

    # parses overall lufs stats
    integrated=$(echo "$lufs_stats" | awk '/I:/ {integrated=$2} END {print integrated}' "$output_file")
    threshold=$(echo "$lufs_stats" | awk '/Threshold:/ {threshold=$2} END {print threshold}' "$output_file")
    lra=$(echo "$lufs_stats" | awk '/LRA:/ {lra=$2} END {print lra}' "$output_file")

    # parses volumes stats
    mean_volume=$(echo "$volume_stats" | awk '/mean_volume:/ {mean=$5} END {print mean}' "$output_file")
    max_volume=$(echo "$volume_stats" | awk '/max_volume:/ {max=$5} END {print max}' "$output_file")

    # parses frame number from data - needed to adapt to any file length
    frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

    # parses spectral centroid value from up to 8 channels and returns the mean value
    centroid_1=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {centroid_1 += $2} END {print centroid_1/'"$frame_count"'}' "$output_file")
    centroid_2=$(echo "$spectral_stats" | awk -F"=" '/2.centroid/ {centroid_2 += $2} END {print centroid_2/'"$frame_count"'}' "$output_file")
    centroid_3=$(echo "$spectral_stats" | awk -F"=" '/3.centroid/ {centroid_3 += $2} END {print centroid_3/'"$frame_count"'}' "$output_file")
    centroid_4=$(echo "$spectral_stats" | awk -F"=" '/4.centroid/ {centroid_4 += $2} END {print centroid_4/'"$frame_count"'}' "$output_file")
    centroid_5=$(echo "$spectral_stats" | awk -F"=" '/5.centroid/ {centroid_5 += $2} END {print centroid_5/'"$frame_count"'}' "$output_file")
    centroid_6=$(echo "$spectral_stats" | awk -F"=" '/6.centroid/ {centroid_6 += $2} END {print centroid_6/'"$frame_count"'}' "$output_file")
    centroid_7=$(echo "$spectral_stats" | awk -F"=" '/7.centroid/ {centroid_7 += $2} END {print centroid_7/'"$frame_count"'}' "$output_file")
    centroid_8=$(echo "$spectral_stats" | awk -F"=" '/8.centroid/ {centroid_8 += $2} END {print centroid_8/'"$frame_count"'}' "$output_file")

    # parses variance value from up to 8 channels and returns the mean value
    variance_1=$(echo "$spectral_stats" | awk -F"=" '/1.variance/ {variance_1 += $2} END {print variance_1/'"$frame_count"'}' "$output_file")
    variance_2=$(echo "$spectral_stats" | awk -F"=" '/2.variance/ {variance_2 += $2} END {print variance_2/'"$frame_count"'}' "$output_file")
    variance_3=$(echo "$spectral_stats" | awk -F"=" '/3.variance/ {variance_3 += $2} END {print variance_3/'"$frame_count"'}' "$output_file")
    variance_4=$(echo "$spectral_stats" | awk -F"=" '/4.variance/ {variance_4 += $2} END {print variance_4/'"$frame_count"'}' "$output_file")
    variance_5=$(echo "$spectral_stats" | awk -F"=" '/5.variance/ {variance_5 += $2} END {print variance_5/'"$frame_count"'}' "$output_file")
    variance_6=$(echo "$spectral_stats" | awk -F"=" '/6.variance/ {variance_6 += $2} END {print variance_6/'"$frame_count"'}' "$output_file")
    variance_7=$(echo "$spectral_stats" | awk -F"=" '/7.variance/ {variance_7 += $2} END {print variance_7/'"$frame_count"'}' "$output_file")
    variance_8=$(echo "$spectral_stats" | awk -F"=" '/8.variance/ {variance_8 += $2} END {print variance_8/'"$frame_count"'}' "$output_file")

    # parses spread value from up to 8 channels and returns the mean value
    spread_1=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {spread_1 += $2} END {print spread_1/'"$frame_count"'}' "$output_file")
    spread_2=$(echo "$spectral_stats" | awk -F"=" '/2.spread/ {spread_2 += $2} END {print spread_2/'"$frame_count"'}' "$output_file")
    spread_3=$(echo "$spectral_stats" | awk -F"=" '/3.spread/ {spread_3 += $2} END {print spread_3/'"$frame_count"'}' "$output_file")
    spread_4=$(echo "$spectral_stats" | awk -F"=" '/4.spread/ {spread_4 += $2} END {print spread_4/'"$frame_count"'}' "$output_file")
    spread_5=$(echo "$spectral_stats" | awk -F"=" '/5.spread/ {spread_5 += $2} END {print spread_5/'"$frame_count"'}' "$output_file")
    spread_6=$(echo "$spectral_stats" | awk -F"=" '/6.spread/ {spread_6 += $2} END {print spread_6/'"$frame_count"'}' "$output_file")
    spread_7=$(echo "$spectral_stats" | awk -F"=" '/7.spread/ {spread_7 += $2} END {print spread_7/'"$frame_count"'}' "$output_file")
    spread_8=$(echo "$spectral_stats" | awk -F"=" '/8.spread/ {spread_8 += $2} END {print spread_8/'"$frame_count"'}' "$output_file")

    # parses skewness value from up to 8 channels and returns the mean value
    skewness_1=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {skewness_1 += $2} END {print skewness_1/'"$frame_count"'}' "$output_file")
    skewness_2=$(echo "$spectral_stats" | awk -F"=" '/2.skewness/ {skewness_2 += $2} END {print skewness_2/'"$frame_count"'}' "$output_file")
    skewness_3=$(echo "$spectral_stats" | awk -F"=" '/3.skewness/ {skewness_3 += $2} END {print skewness_3/'"$frame_count"'}' "$output_file")
    skewness_4=$(echo "$spectral_stats" | awk -F"=" '/4.skewness/ {skewness_4 += $2} END {print skewness_4/'"$frame_count"'}' "$output_file")
    skewness_5=$(echo "$spectral_stats" | awk -F"=" '/5.skewness/ {skewness_5 += $2} END {print skewness_5/'"$frame_count"'}' "$output_file")
    skewness_6=$(echo "$spectral_stats" | awk -F"=" '/6.skewness/ {skewness_6 += $2} END {print skewness_6/'"$frame_count"'}' "$output_file")
    skewness_7=$(echo "$spectral_stats" | awk -F"=" '/7.skewness/ {skewness_7 += $2} END {print skewness_7/'"$frame_count"'}' "$output_file")
    skewness_8=$(echo "$spectral_stats" | awk -F"=" '/8.skewness/ {skewness_8 += $2} END {print skewness_8/'"$frame_count"'}' "$output_file")

    # parses kurtosis value from up to 8 channels and returns the mean value
    kurtosis_1=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {kurtosis_1 += $2} END {print kurtosis_1/'"$frame_count"'}' "$output_file")
    kurtosis_2=$(echo "$spectral_stats" | awk -F"=" '/2.kurtosis/ {kurtosis_2 += $2} END {print kurtosis_2/'"$frame_count"'}' "$output_file")
    kurtosis_3=$(echo "$spectral_stats" | awk -F"=" '/3.kurtosis/ {kurtosis_3 += $2} END {print kurtosis_3/'"$frame_count"'}' "$output_file")
    kurtosis_4=$(echo "$spectral_stats" | awk -F"=" '/4.kurtosis/ {kurtosis_4 += $2} END {print kurtosis_4/'"$frame_count"'}' "$output_file")
    kurtosis_5=$(echo "$spectral_stats" | awk -F"=" '/5.kurtosis/ {kurtosis_5 += $2} END {print kurtosis_5/'"$frame_count"'}' "$output_file")
    kurtosis_6=$(echo "$spectral_stats" | awk -F"=" '/6.kurtosis/ {kurtosis_6 += $2} END {print kurtosis_6/'"$frame_count"'}' "$output_file")
    kurtosis_7=$(echo "$spectral_stats" | awk -F"=" '/7.kurtosis/ {kurtosis_7 += $2} END {print kurtosis_7/'"$frame_count"'}' "$output_file")
    kurtosis_8=$(echo "$spectral_stats" | awk -F"=" '/8.kurtosis/ {kurtosis_8 += $2} END {print kurtosis_8/'"$frame_count"'}' "$output_file")

    # parses entropy value from up to 8 channels and returns the mean value
    entropy_1=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {entropy_1 += $2} END {print entropy_1/'"$frame_count"'}' "$output_file")
    entropy_2=$(echo "$spectral_stats" | awk -F"=" '/2.entropy/ {entropy_2 += $2} END {print entropy_2/'"$frame_count"'}' "$output_file")
    entropy_3=$(echo "$spectral_stats" | awk -F"=" '/3.entropy/ {entropy_3 += $2} END {print entropy_3/'"$frame_count"'}' "$output_file")
    entropy_4=$(echo "$spectral_stats" | awk -F"=" '/4.entropy/ {entropy_4 += $2} END {print entropy_4/'"$frame_count"'}' "$output_file")
    entropy_5=$(echo "$spectral_stats" | awk -F"=" '/5.entropy/ {entropy_5 += $2} END {print entropy_5/'"$frame_count"'}' "$output_file")
    entropy_6=$(echo "$spectral_stats" | awk -F"=" '/6.entropy/ {entropy_6 += $2} END {print entropy_6/'"$frame_count"'}' "$output_file")
    entropy_7=$(echo "$spectral_stats" | awk -F"=" '/7.entropy/ {entropy_7 += $2} END {print entropy_7/'"$frame_count"'}' "$output_file")
    entropy_8=$(echo "$spectral_stats" | awk -F"=" '/8.entropy/ {entropy_8 += $2} END {print entropy_8/'"$frame_count"'}' "$output_file")

    # parses flatness value from up to 8 channels and returns the mean value
    flatness_1=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {flatness_1 += $2} END {print flatness_1/'"$frame_count"'}' "$output_file")
    flatness_2=$(echo "$spectral_stats" | awk -F"=" '/2.flatness/ {flatness_2 += $2} END {print flatness_2/'"$frame_count"'}' "$output_file")
    flatness_3=$(echo "$spectral_stats" | awk -F"=" '/3.flatness/ {flatness_3 += $2} END {print flatness_3/'"$frame_count"'}' "$output_file")
    flatness_4=$(echo "$spectral_stats" | awk -F"=" '/4.flatness/ {flatness_4 += $2} END {print flatness_4/'"$frame_count"'}' "$output_file")
    flatness_5=$(echo "$spectral_stats" | awk -F"=" '/5.flatness/ {flatness_5 += $2} END {print flatness_5/'"$frame_count"'}' "$output_file")
    flatness_6=$(echo "$spectral_stats" | awk -F"=" '/6.flatness/ {flatness_6 += $2} END {print flatness_6/'"$frame_count"'}' "$output_file")
    flatness_7=$(echo "$spectral_stats" | awk -F"=" '/7.flatness/ {flatness_7 += $2} END {print flatness_7/'"$frame_count"'}' "$output_file")
    flatness_8=$(echo "$spectral_stats" | awk -F"=" '/8.flatness/ {flatness_8 += $2} END {print flatness_8/'"$frame_count"'}' "$output_file")

    # parses crest value from up to 8 channels and returns the mean value
    crest_1=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {crest_1 += $2} END {print crest_1/'"$frame_count"'}' "$output_file")
    crest_2=$(echo "$spectral_stats" | awk -F"=" '/2.crest/ {crest_2 += $2} END {print crest_2/'"$frame_count"'}' "$output_file")
    crest_3=$(echo "$spectral_stats" | awk -F"=" '/3.crest/ {crest_3 += $2} END {print crest_3/'"$frame_count"'}' "$output_file")
    crest_4=$(echo "$spectral_stats" | awk -F"=" '/4.crest/ {crest_4 += $2} END {print crest_4/'"$frame_count"'}' "$output_file")
    crest_5=$(echo "$spectral_stats" | awk -F"=" '/5.crest/ {crest_5 += $2} END {print crest_5/'"$frame_count"'}' "$output_file")
    crest_6=$(echo "$spectral_stats" | awk -F"=" '/6.crest/ {crest_6 += $2} END {print crest_6/'"$frame_count"'}' "$output_file")
    crest_7=$(echo "$spectral_stats" | awk -F"=" '/7.crest/ {crest_7 += $2} END {print crest_7/'"$frame_count"'}' "$output_file")
    crest_8=$(echo "$spectral_stats" | awk -F"=" '/8.crest/ {crest_8 += $2} END {print crest_8/'"$frame_count"'}' "$output_file")

    # parses flux value from up to 8 channels and returns the mean value
    flux_1=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {flux_1 += $2} END {print flux_1/'"$frame_count"'}' "$output_file")
    flux_2=$(echo "$spectral_stats" | awk -F"=" '/2.flux/ {flux_2 += $2} END {print flux_2/'"$frame_count"'}' "$output_file")
    flux_3=$(echo "$spectral_stats" | awk -F"=" '/3.flux/ {flux_3 += $2} END {print flux_3/'"$frame_count"'}' "$output_file")
    flux_4=$(echo "$spectral_stats" | awk -F"=" '/4.flux/ {flux_4 += $2} END {print flux_4/'"$frame_count"'}' "$output_file")
    flux_5=$(echo "$spectral_stats" | awk -F"=" '/5.flux/ {flux_5 += $2} END {print flux_5/'"$frame_count"'}' "$output_file")
    flux_6=$(echo "$spectral_stats" | awk -F"=" '/6.flux/ {flux_6 += $2} END {print flux_6/'"$frame_count"'}' "$output_file")
    flux_7=$(echo "$spectral_stats" | awk -F"=" '/7.flux/ {flux_7 += $2} END {print flux_7/'"$frame_count"'}' "$output_file")
    flux_8=$(echo "$spectral_stats" | awk -F"=" '/8.flux/ {flux_8 += $2} END {print flux_8/'"$frame_count"'}' "$output_file")

    # parses slope value from up to 8 channels and returns the mean value
    slope_1=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {slope_1 += $2} END {print slope_1/'"$frame_count"'}' "$output_file")
    slope_2=$(echo "$spectral_stats" | awk -F"=" '/2.slope/ {slope_2 += $2} END {print slope_2/'"$frame_count"'}' "$output_file")
    slope_3=$(echo "$spectral_stats" | awk -F"=" '/3.slope/ {slope_3 += $2} END {print slope_3/'"$frame_count"'}' "$output_file")
    slope_4=$(echo "$spectral_stats" | awk -F"=" '/4.slope/ {slope_4 += $2} END {print slope_4/'"$frame_count"'}' "$output_file")
    slope_5=$(echo "$spectral_stats" | awk -F"=" '/5.slope/ {slope_5 += $2} END {print slope_5/'"$frame_count"'}' "$output_file")
    slope_6=$(echo "$spectral_stats" | awk -F"=" '/6.slope/ {slope_6 += $2} END {print slope_6/'"$frame_count"'}' "$output_file")
    slope_7=$(echo "$spectral_stats" | awk -F"=" '/7.slope/ {slope_7 += $2} END {print slope_7/'"$frame_count"'}' "$output_file")
    slope_8=$(echo "$spectral_stats" | awk -F"=" '/8.slope/ {slope_8 += $2} END {print slope_8/'"$frame_count"'}' "$output_file")

    # parses decrease value from up to 8 channels and returns the mean value
    decrease_1=$(echo "$spectral_stats" | awk -F"=" '/1.decrease/ {decrease_1 += $2} END {print decrease_1/'"$frame_count"'}' "$output_file")
    decrease_2=$(echo "$spectral_stats" | awk -F"=" '/2.decrease/ {decrease_2 += $2} END {print decrease_2/'"$frame_count"'}' "$output_file")
    decrease_3=$(echo "$spectral_stats" | awk -F"=" '/3.decrease/ {decrease_3 += $2} END {print decrease_3/'"$frame_count"'}' "$output_file")
    decrease_4=$(echo "$spectral_stats" | awk -F"=" '/4.decrease/ {decrease_4 += $2} END {print decrease_4/'"$frame_count"'}' "$output_file")
    decrease_5=$(echo "$spectral_stats" | awk -F"=" '/5.decrease/ {decrease_5 += $2} END {print decrease_5/'"$frame_count"'}' "$output_file")
    decrease_6=$(echo "$spectral_stats" | awk -F"=" '/6.decrease/ {decrease_6 += $2} END {print decrease_6/'"$frame_count"'}' "$output_file")
    decrease_7=$(echo "$spectral_stats" | awk -F"=" '/7.decrease/ {decrease_7 += $2} END {print decrease_7/'"$frame_count"'}' "$output_file")
    decrease_8=$(echo "$spectral_stats" | awk -F"=" '/8.decrease/ {decrease_8 += $2} END {print decrease_8/'"$frame_count"'}' "$output_file")

    # parses rolloff value from up to 8 channels and returns the mean value
    rolloff_1=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {rolloff_1 += $2} END {print rolloff_1/'"$frame_count"'}' "$output_file")
    rolloff_2=$(echo "$spectral_stats" | awk -F"=" '/2.rolloff/ {rolloff_2 += $2} END {print rolloff_2/'"$frame_count"'}' "$output_file")
    rolloff_3=$(echo "$spectral_stats" | awk -F"=" '/3.rolloff/ {rolloff_3 += $2} END {print rolloff_3/'"$frame_count"'}' "$output_file")
    rolloff_4=$(echo "$spectral_stats" | awk -F"=" '/4.rolloff/ {rolloff_4 += $2} END {print rolloff_4/'"$frame_count"'}' "$output_file")
    rolloff_5=$(echo "$spectral_stats" | awk -F"=" '/5.rolloff/ {rolloff_5 += $2} END {print rolloff_5/'"$frame_count"'}' "$output_file")
    rolloff_6=$(echo "$spectral_stats" | awk -F"=" '/6.rolloff/ {rolloff_6 += $2} END {print rolloff_6/'"$frame_count"'}' "$output_file")
    rolloff_7=$(echo "$spectral_stats" | awk -F"=" '/7.rolloff/ {rolloff_7 += $2} END {print rolloff_7/'"$frame_count"'}' "$output_file")
    rolloff_8=$(echo "$spectral_stats" | awk -F"=" '/8.rolloff/ {rolloff_8 += $2} END {print rolloff_8/'"$frame_count"'}' "$output_file")

    filename="$file"

    echo '
{
    "metadata": '"$meta_stats"',
    "loudness": {
        "max_volume": '"$max_volume"',
        "mean_volume": '"$mean_volume"',
        "integrated_lufs": '"$integrated"',
        "threshold": '"$threshold"',
        "lra": '"$lra"'
    },
    "spectral": {
        "centroid": {
            "ch1": '"$centroid_1"',
            "ch2": '"$centroid_2"',
            "ch3": '"$centroid_3"',
            "ch4": '"$centroid_4"',
            "ch5": '"$centroid_5"',
            "ch6": '"$centroid_6"',
            "ch7": '"$centroid_7"',
            "ch8": '"$centroid_8"'
        },
        "variance": {
            "ch1": '"$variance_1"',
            "ch2": '"$variance_2"',
            "ch3": '"$variance_3"',
            "ch4": '"$variance_4"',
            "ch5": '"$variance_5"',
            "ch6": '"$variance_6"',
            "ch7": '"$variance_7"',
            "ch8": '"$variance_8"'
        },
        "spread": {
            "ch1": '"$spread_1"',
            "ch2": '"$spread_2"',
            "ch3": '"$spread_3"',
            "ch4": '"$spread_4"',
            "ch5": '"$spread_5"',
            "ch6": '"$spread_6"',
            "ch7": '"$spread_7"',
            "ch8": '"$spread_8"'
        },
        "skewness": {
            "ch1": '"$skewness_1"',
            "ch2": '"$skewness_2"',
            "ch3": '"$skewness_3"',
            "ch4": '"$skewness_4"',
            "ch5": '"$skewness_5"',
            "ch6": '"$skewness_6"',
            "ch7": '"$skewness_7"',
            "ch8": '"$skewness_8"'
        },
        "kurtosis": {
            "ch1": '"$kurtosis_1"',
            "ch2": '"$kurtosis_2"',
            "ch3": '"$kurtosis_3"',
            "ch4": '"$kurtosis_4"',
            "ch5": '"$kurtosis_5"',
            "ch6": '"$kurtosis_6"',
            "ch7": '"$kurtosis_7"',
            "ch8": '"$kurtosis_8"'
        },
        "entropy": {
            "ch1": '"$entropy_1"',
            "ch2": '"$entropy_2"',
            "ch3": '"$entropy_3"',
            "ch4": '"$entropy_4"',
            "ch5": '"$entropy_5"',
            "ch6": '"$entropy_6"',
            "ch7": '"$entropy_7"',
            "ch8": '"$entropy_8"'
        },
        "flatness": {
            "ch1": '"$flatness_1"',
            "ch2": '"$flatness_2"',
            "ch3": '"$flatness_3"',
            "ch4": '"$flatness_4"',
            "ch5": '"$flatness_5"',
            "ch6": '"$flatness_6"',
            "ch7": '"$flatness_7"',
            "ch8": '"$flatness_8"'
        },
        "crest": {
            "ch1": '"$crest_1"',
            "ch2": '"$crest_2"',
            "ch3": '"$crest_3"',
            "ch4": '"$crest_4"',
            "ch5": '"$crest_5"',
            "ch6": '"$crest_6"',
            "ch7": '"$crest_7"',
            "ch8": '"$crest_8"'
        },
        "flux": {
            "ch1": '"$flux_1"',
            "ch2": '"$flux_2"',
            "ch3": '"$flux_3"',
            "ch4": '"$flux_4"',
            "ch5": '"$flux_5"',
            "ch6": '"$flux_6"',
            "ch7": '"$flux_7"',
            "ch8": '"$flux_8"'
        },
        "slope": {
            "ch1": '"$slope_1"',
            "ch2": '"$slope_2"',
            "ch3": '"$slope_3"',
            "ch4": '"$slope_4"',
            "ch5": '"$slope_5"',
            "ch6": '"$slope_6"',
            "ch7": '"$slope_7"',
            "ch8": '"$slope_8"'
        },
        "decrease": {
            "ch1": '"$decrease_1"',
            "ch2": '"$decrease_2"',
            "ch3": '"$decrease_3"',
            "ch4": '"$decrease_4"',
            "ch5": '"$decrease_5"',
            "ch6": '"$decrease_6"',
            "ch7": '"$decrease_7"',
            "ch8": '"$decrease_8"'
        },
        "rolloff": {
            "ch1": '"$rolloff_1"',
            "ch2": '"$rolloff_2"',
            "ch3": '"$rolloff_3"',
            "ch4": '"$rolloff_4"',
            "ch5": '"$rolloff_5"',
            "ch6": '"$rolloff_6"',
            "ch7": '"$rolloff_7"',
            "ch8": '"$rolloff_8"'
        },
    "frame_count": '"$frame_count"'
    }
}' > ."$filename".json
done

rm "$output_file"

output_file=".output_data.txt"
echo " " > "$output_file"

# Check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
  echo "Error: jq is not installed. Please install jq first."
  exit 1
fi

# Parse the arguments
keys=(
  metadata.format.duration
  loudness.max_volume
  loudness.mean_volume
  loudness.integrated_lufs
  loudness.threshold
  loudness.lra
  spectral.centroid.ch1
  spectral.centroid.ch2
  spectral.variance.ch1
  spectral.variance.ch2
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
  )

# Function to extract JSON values
get_json_value() {
  local file="$1"
  local key="$2"
  local value
  value=$(jq -r ".$key" "$file")
  echo "$value"
}

# Get a list of all JSON files in the current directory
json_files=(.*.json)

# Calculate similarity for each pair of files and keys
for ((i = 0; i < ${#json_files[@]}; i++)); do
  for ((j = i + 1; j < ${#json_files[@]}; j++)); do
    file1="${json_files[$i]}"
    file2="${json_files[$j]}"
    similarity=0

    for key in "${keys[@]}"; do
      value1=$(get_json_value "$file1" "$key")
      value2=$(get_json_value "$file2" "$key")

      diff=$(echo "$value1 - $value2" | bc -l)
      diff_abs=$(echo "$diff" | awk '{print ($1 < 0) ? -$1 : $1}')

      echo "$file1 vs $file2: $key: $value1 (File1), $value2 (File2), Absolute Difference: $diff_abs"
      similarity=$(echo "$similarity + $diff_abs")
    done >> "$output_file"

    #echo "$file1 vs $file2: Total Similarity: $similarity"
  done
done
