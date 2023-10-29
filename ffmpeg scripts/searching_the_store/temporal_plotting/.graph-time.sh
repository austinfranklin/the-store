argument=arg

# formatting
set origin -3, 0
set tmargin 5
set bmargin 5
set size 4, 1
unset xtics
set yrange[0:1]

# labels
set xlabel "Time"
set ylabel "Normalized Values"

# styling
set boxwidth 0.75
set style fill solid 1.0

# use line number for x coordinate, column 1 for tic label
set term png large size 2500, 1800
set output arg

set multiplot layout 3,4
set title "Spectral Centroid"
plot ".centroid_l.txt" using 1 with linespoints title "Left Channel", \
    ".centroid_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Variance"
plot ".variance_l.txt" using 1 with linespoints title "Left Channel", \
    ".variance_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Spread"
plot ".spread_l.txt" using 1 with linespoints title "Left Channel", \
    ".spread_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Skewness"
plot ".skewness_l.txt" using 1 with linespoints title "Left Channel", \
    ".skewness_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Kurtosis"
plot ".kurtosis_l.txt" using 1 with linespoints title "Left Channel", \
    ".kurtosis_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Entropy"
plot ".entropy_l.txt" using 1 with linespoints title "Left Channel", \
    ".entropy_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Flatness"
plot ".flatness_l.txt" using 1 with linespoints title "Left Channel", \
    ".flatness_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Crest"
plot ".crest_l.txt" using 1 with linespoints title "Left Channel", \
    ".crest_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Flux"
plot ".flux_l.txt" using 1 with linespoints title "Left Channel", \
    ".flux_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Slope"
plot ".slope_l.txt" using 1 with linespoints title "Left Channel", \
    ".slope_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Decrease"
plot ".decrease_l.txt" using 1 with linespoints title "Left Channel", \
    ".decrease_r.txt" using 1 with linespoints title "Right Channel"

set title "Spectral Rolloff"
plot ".rolloff_l.txt" using 1 with linespoints title "Left Channel", \
    ".rolloff_r.txt" using 1 with linespoints title "Right Channel"
unset multiplot
