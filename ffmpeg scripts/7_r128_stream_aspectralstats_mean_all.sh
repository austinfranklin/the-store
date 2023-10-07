# finds metadata AND spectral data AND loudness data - outputs in JSON format - JSON is kind of ugly
output_file="raw_data.txt"
output_json="meta_loud_aspectralstats_mean_json.json"

for file in *.*; do
    # main command - analysis done here
    meta_stats=$(ffprobe -v quiet -print_format json -show_format -show_streams -hide_banner -i "$file")
    lufs_stats=$(ffmpeg -i "$file" -af ebur128=framelog=verbose -f null - 2>> "$output_file")
    volume_stats=$(ffmpeg -i "$file" -filter:a volumedetect -f null - 2>> "$output_file")
    spectral_stats=$(ffmpeg -i "$file" -af aspectralstats=measure=all:win_size=65536,ametadata=print:file=- -f null - >> "$output_file")

    # parses overall loudness stats
    integrated=$(echo "$lufs_stats" | awk '/I:/ {integrated=$2} END {print integrated}' "$output_file")
    lra=$(echo "$lufs_stats" | awk '/LRA:/ {lra=$2} END {print lra}' "$output_file")

    # parses volumes stats
    mean_volume=$(echo "$volume_stats" | awk '/mean_volume:/ {mean=$5} END {print mean}' "$output_file")
    max_volume=$(echo "$volume_stats" | awk '/max_volume:/ {max=$5} END {print max}' "$output_file")

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
            "max_volume": '"$max_volume"',
            "mean_volume": '"$mean_volume"',
            "integrated_lufs": '"$integrated"',
            "lra": '"$lra"',
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