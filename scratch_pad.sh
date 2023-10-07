# General ffmpeg structure...
## ffmpeg [global_options] {[input_file_options] -i input_url} ... {[output_file_options] output_url} ...

# --------------------------------------------------------------------------------

# Useful commands...
## get help
### ffmpeg -h
#### man ffmpeg (hardcore)
## gives list of all available formats
### ffmpeg -formats
## get info
### ffmpeg -i input.file -hide_banner
## play a file
### ffplay input.file

# --------------------------------------------------------------------------------

# writes astats data to .txt file on desktop - WORKS BUT DOESN'T OUTPUT IN JSON
output_file=~/Desktop/astats.txt

for file in *.*; do
    ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -filter:a astats=metadata=1:measure_overall=1,ametadata=print:key=lavfi.astats.Overall.all:file=- -f null - 2>> "$output_file"
done

# --------------------------------------------------------------------------------

# retreives aspectralstats (all)
ffmpeg -hide_banner -v error -i file.wav -af aspectralstats,ametadata=print:file=- -f null -

# replace 'aspectralstats=measure=ARG' from one of the following to narrow retrieval:
# mean
# variance
# centroid
# spread
# skewness
# kurtosis
# entropy
# flatness
# crest
# flux
# slope
# decrease
# rolloff

# --------------------------------------------------------------------------------

# writes aspectralstats data to .txt file on desktop - WORKS BUT OUTPUTS VALUE EVERY FRAME!
file="flute-speech.mp3"

output_file="$HOME/Desktop/aspectralstats.txt"

ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -af aspectralstats=measure=centroid:win_size=2048,ametadata=print:file=- -f null - > "$output_file"

# --------------------------------------------------------------------------------

# finds the mean spectral centroid of an audio file
# Input audio file
file="input.wav"

output_file="$HOME/Desktop/aspectralstats_mean.txt"

spectral_stats=$(ffprobe -hide_banner -v error -print_format json -i "$file" | ffmpeg -i "$file" -af aspectralstats=measure=centroid:win_size=2048,ametadata=print:file=- -f null - > "$output_file")

# parses frame number from data - needed to adapt to any file length
frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

# parses spectral centroid value from left and right channels
left_centroid=$(echo "$spectral_stats" | grep "centroid" "$output_file" | awk -F"=" '{sum += $2} END {print sum/'"$frame_count"'}' "$output_file")
right_centroid=$(echo "$spectral_stats" | grep "centroid" "$output_file" | awk -F"=" '{sum += $2} END {print sum/'"$frame_count"'}' "$output_file")

echo "Left channel centroid: "$left_centroid" and right channel centroid: "$right_centroid" with "$frame_count" number of frames."

# --------------------------------------------------------------------------------

# finds the mean spectral values of all files in a folder
# make sure you're inside the directory you want to analyze
output_file="$HOME/Desktop/raw_data.txt"
output_json="$HOME/Desktop/aspectralstats_mean_json.json"

for file in *.*; do
    # main command - spectral analysis done here
    spectral_stats=$(ffmpeg -i "$file" -af aspectralstats=measure=all:win_size=65536,ametadata=print:file=- -f null - > "$output_file")

    # parses frame number from data - needed to adapt to any file length
    frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

    # parses spectral centroid value from left and right channels and returns the mean value
    left_centroid=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {l_centroid += $2} END {print l_centroid/'"$frame_count"'}' "$output_file")
    right_centroid=$(echo "$spectral_stats" | awk -F"=" '/2.centroid/ {r_centroid += $2} END {print r_centroid/'"$frame_count"'}' "$output_file")

    # parses variance value from left and right channels and returns the mean value
    left_variance=$(echo "$spectral_stats" | awk -F"=" '/1.variance/ {l_variance += $2} END {print l_variance/'"$frame_count"'}' "$output_file")
    right_variance=$(echo "$spectral_stats" | awk -F"=" '/2.variance/ {r_variance += $2} END {print r_variance/'"$frame_count"'}' "$output_file")

    # parses spread value from left and right channels and returns the mean value
    left_spread=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {l_spread += $2} END {print l_spread/'"$frame_count"'}' "$output_file")
    right_spread=$(echo "$spectral_stats" | awk -F"=" '/2.spread/ {r_spread += $2} END {print r_spread/'"$frame_count"'}' "$output_file")

    # parses skewness value from left and right channels and returns the mean value
    left_skewness=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {l_skewness += $2} END {print l_skewness/'"$frame_count"'}' "$output_file")
    right_skewness=$(echo "$spectral_stats" | awk -F"=" '/2.skewness/ {r_skewness += $2} END {print r_skewness/'"$frame_count"'}' "$output_file")

    # parses kurtosis value from left and right channels and returns the mean value
    left_kurtosis=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {l_kurtosis += $2} END {print l_kurtosis/'"$frame_count"'}' "$output_file")
    right_kurtosis=$(echo "$spectral_stats" | awk -F"=" '/2.kurtosis/ {r_kurtosis += $2} END {print r_kurtosis/'"$frame_count"'}' "$output_file")

    # parses entropy value from left and right channels and returns the mean value
    left_entropy=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {l_entropy += $2} END {print l_entropy/'"$frame_count"'}' "$output_file")
    right_entropy=$(echo "$spectral_stats" | awk -F"=" '/2.entropy/ {r_entropy += $2} END {print r_entropy/'"$frame_count"'}' "$output_file")

    # parses flatness value from left and right channels and returns the mean value
    left_flatness=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {l_flatness += $2} END {print l_flatness/'"$frame_count"'}' "$output_file")
    right_flatness=$(echo "$spectral_stats" | awk -F"=" '/2.flatness/ {r_flatness += $2} END {print r_flatness/'"$frame_count"'}' "$output_file")

    # parses crest value from left and right channels and returns the mean value
    left_crest=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {l_crest += $2} END {print l_crest/'"$frame_count"'}' "$output_file")
    right_crest=$(echo "$spectral_stats" | awk -F"=" '/2.crest/ {r_crest += $2} END {print r_crest/'"$frame_count"'}' "$output_file")

    # parses flux value from left and right channels and returns the mean value
    left_flux=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {l_flux += $2} END {print l_flux/'"$frame_count"'}' "$output_file")
    right_flux=$(echo "$spectral_stats" | awk -F"=" '/2.flux/ {r_flux += $2} END {print r_flux/'"$frame_count"'}' "$output_file")

    # parses slope value from left and right channels and returns the mean value
    left_slope=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {l_slope += $2} END {print l_slope/'"$frame_count"'}' "$output_file")
    right_slope=$(echo "$spectral_stats" | awk -F"=" '/2.slope/ {r_slope += $2} END {print r_slope/'"$frame_count"'}' "$output_file")

    # parses decrease value from left and right channels and returns the mean value
    left_decrease=$(echo "$spectral_stats" | awk -F"=" '/1.decrease/ {l_decrease += $2} END {print l_decrease/'"$frame_count"'}' "$output_file")
    right_decrease=$(echo "$spectral_stats" | awk -F"=" '/2.decrease/ {r_decrease += $2} END {print r_decrease/'"$frame_count"'}' "$output_file")

    # parses rolloff value from left and right channels and returns the mean value
    left_rolloff=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {l_rolloff += $2} END {print l_rolloff/'"$frame_count"'}' "$output_file")
    right_rolloff=$(echo "$spectral_stats" | awk -F"=" '/2.rolloff/ {r_rolloff += $2} END {print r_rolloff/'"$frame_count"'}' "$output_file")

    echo '{
            filename: '"$file"',
            centroid_left: '"$left_centroid"',
            centroid_right: '"$right_centroid"',
            variance_left: '"$left_variance"',
            variance_right: '"$right_variance"',
            spread_left: '"$left_spread"',
            spread_right: '"$right_spread"',
            skewness_left: '"$left_skewness"',
            skewness_right: '"$right_skewness"',
            kurtosis_left: '"$left_kurtosis"',
            kurtosis_right: '"$right_kurtosis"',
            entropy_left: '"$left_entropy"',
            entropy_right: '"$right_entropy"',
            flatness_left: '"$left_flatness"',
            flatness_right: '"$right_flatness"',
            crest_left: '"$left_crest"',
            crest_right: '"$right_crest"',
            flux_left: '"$left_flux"',
            flux_right: '"$right_flux"',
            slope_left: '"$left_slope"',
            slope_right: '"$right_slope"',
            descrease_left: '"$left_decrease"',
            decrease_right: '"$right_decrease"',
            rolloff_left: '"$left_rolloff"',
            rolloff_right: '"$right_rolloff"',
            frame_count: '"$frame_count"'
        }' >> "$output_json"
done

# --------------------------------------------------------------------------------

# finds metadata AND spectral data - outputs in JSON format - JSON is kind of ugly
output_file="$HOME/Desktop/raw_data.txt"
output_json="$HOME/Desktop/meta_aspectralstats_mean_json.json"

for file in *.*; do
    # main command - spectral analysis done here
    meta_stats=$(ffprobe -v quiet -print_format json -show_streams -show_format -hide_banner -i "$file")
    spectral_stats=$(ffmpeg -i "$file" -af aspectralstats=measure=all:win_size=65536,ametadata=print:file=- -f null - >> "$output_file")

    # parses frame number from data - needed to adapt to any file length
    frame_count=$(echo "$spectral_stats" | awk '/frame/ {count++} END {print count}' $output_file)

    # parses spectral centroid value from left and right channels and returns the mean value
    left_centroid=$(echo "$spectral_stats" | awk -F"=" '/1.centroid/ {l_centroid += $2} END {print l_centroid/'"$frame_count"'}' "$output_file")
    right_centroid=$(echo "$spectral_stats" | awk -F"=" '/2.centroid/ {r_centroid += $2} END {print r_centroid/'"$frame_count"'}' "$output_file")

    # parses variance value from left and right channels and returns the mean value
    left_variance=$(echo "$spectral_stats" | awk -F"=" '/1.variance/ {l_variance += $2} END {print l_variance/'"$frame_count"'}' "$output_file")
    right_variance=$(echo "$spectral_stats" | awk -F"=" '/2.variance/ {r_variance += $2} END {print r_variance/'"$frame_count"'}' "$output_file")

    # parses spread value from left and right channels and returns the mean value
    left_spread=$(echo "$spectral_stats" | awk -F"=" '/1.spread/ {l_spread += $2} END {print l_spread/'"$frame_count"'}' "$output_file")
    right_spread=$(echo "$spectral_stats" | awk -F"=" '/2.spread/ {r_spread += $2} END {print r_spread/'"$frame_count"'}' "$output_file")

    # parses skewness value from left and right channels and returns the mean value
    left_skewness=$(echo "$spectral_stats" | awk -F"=" '/1.skewness/ {l_skewness += $2} END {print l_skewness/'"$frame_count"'}' "$output_file")
    right_skewness=$(echo "$spectral_stats" | awk -F"=" '/2.skewness/ {r_skewness += $2} END {print r_skewness/'"$frame_count"'}' "$output_file")

    # parses kurtosis value from left and right channels and returns the mean value
    left_kurtosis=$(echo "$spectral_stats" | awk -F"=" '/1.kurtosis/ {l_kurtosis += $2} END {print l_kurtosis/'"$frame_count"'}' "$output_file")
    right_kurtosis=$(echo "$spectral_stats" | awk -F"=" '/2.kurtosis/ {r_kurtosis += $2} END {print r_kurtosis/'"$frame_count"'}' "$output_file")

    # parses entropy value from left and right channels and returns the mean value
    left_entropy=$(echo "$spectral_stats" | awk -F"=" '/1.entropy/ {l_entropy += $2} END {print l_entropy/'"$frame_count"'}' "$output_file")
    right_entropy=$(echo "$spectral_stats" | awk -F"=" '/2.entropy/ {r_entropy += $2} END {print r_entropy/'"$frame_count"'}' "$output_file")

    # parses flatness value from left and right channels and returns the mean value
    left_flatness=$(echo "$spectral_stats" | awk -F"=" '/1.flatness/ {l_flatness += $2} END {print l_flatness/'"$frame_count"'}' "$output_file")
    right_flatness=$(echo "$spectral_stats" | awk -F"=" '/2.flatness/ {r_flatness += $2} END {print r_flatness/'"$frame_count"'}' "$output_file")

    # parses crest value from left and right channels and returns the mean value
    left_crest=$(echo "$spectral_stats" | awk -F"=" '/1.crest/ {l_crest += $2} END {print l_crest/'"$frame_count"'}' "$output_file")
    right_crest=$(echo "$spectral_stats" | awk -F"=" '/2.crest/ {r_crest += $2} END {print r_crest/'"$frame_count"'}' "$output_file")

    # parses flux value from left and right channels and returns the mean value
    left_flux=$(echo "$spectral_stats" | awk -F"=" '/1.flux/ {l_flux += $2} END {print l_flux/'"$frame_count"'}' "$output_file")
    right_flux=$(echo "$spectral_stats" | awk -F"=" '/2.flux/ {r_flux += $2} END {print r_flux/'"$frame_count"'}' "$output_file")

    # parses slope value from left and right channels and returns the mean value
    left_slope=$(echo "$spectral_stats" | awk -F"=" '/1.slope/ {l_slope += $2} END {print l_slope/'"$frame_count"'}' "$output_file")
    right_slope=$(echo "$spectral_stats" | awk -F"=" '/2.slope/ {r_slope += $2} END {print r_slope/'"$frame_count"'}' "$output_file")

    # parses decrease value from left and right channels and returns the mean value
    left_decrease=$(echo "$spectral_stats" | awk -F"=" '/1.decrease/ {l_decrease += $2} END {print l_decrease/'"$frame_count"'}' "$output_file")
    right_decrease=$(echo "$spectral_stats" | awk -F"=" '/2.decrease/ {r_decrease += $2} END {print r_decrease/'"$frame_count"'}' "$output_file")

    # parses rolloff value from left and right channels and returns the mean value
    left_rolloff=$(echo "$spectral_stats" | awk -F"=" '/1.rolloff/ {l_rolloff += $2} END {print l_rolloff/'"$frame_count"'}' "$output_file")
    right_rolloff=$(echo "$spectral_stats" | awk -F"=" '/2.rolloff/ {r_rolloff += $2} END {print r_rolloff/'"$frame_count"'}' "$output_file")

    echo '{
            "metadata": '"$meta_stats"',
            "centroid_left": '"$left_centroid"',
            "centroid_right": '"$right_centroid"',
            "variance_left": '"$left_variance"',
            "variance_right": '"$right_variance"',
            "spread_left": '"$left_spread"',
            "spread_right": '"$right_spread"',
            "skewness_left": '"$left_skewness"',
            "skewness_right": '"$right_skewness"',
            "kurtosis_left": '"$left_kurtosis"',
            "kurtosis_right": '"$right_kurtosis"',
            "entropy_left": '"$left_entropy"',
            "entropy_right": '"$right_entropy"',
            "flatness_left": '"$left_flatness"',
            "flatness_right": '"$right_flatness"',
            "crest_left": '"$left_crest"',
            "crest_right": '"$right_crest"',
            "flux_left": '"$left_flux"',
            "flux_right": '"$right_flux"',
            "slope_left": '"$left_slope"',
            "slope_right": '"$right_slope"',
            "decrease_left": '"$left_decrease"',
            "decrease_right": '"$right_decrease"',
            "rolloff_left": '"$left_rolloff"',
            "rolloff_right": '"$right_rolloff"',
            "frame_count": '"$frame_count"'
        }' >> "$output_json"
done

# --------------------------------------------------------------------------------

# command for analyzing loudness - all metrics
ffmpeg -i flute-speech.mp3 -hide_banner -filter_complex ebur128 -f null -
ffmpeg -i flute-speech.mp3 -af ebur128=framelog=verbose -f null -

ffmpeg -i flute-speech.mp3 -af ebur128=framelog=verbose -f null - 2>&1 | awk '/I:/{print $2}'
ffmpeg -i flute-speech.mp3 -af ebur128=framelog=verbose -f null - 2>&1 | awk '/LRA:/{print $2}'