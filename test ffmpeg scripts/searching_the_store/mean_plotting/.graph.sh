argument=arg

# formatting
set origin -3, 0
set tmargin 5
set bmargin 15
set size 4, 1
set xtics rotate out
set yrange[0:1]

# labels
set xlabel "Features/Files"
set ylabel "Normalized Values"
set title "Feature Extraction of ".arg

# styling
set boxwidth 0.75
set style fill solid 1.0

# use line number for x coordinate, column 1 for tic label
set term png
set output arg
plot ".graph_file.txt" u 2:xtic(1) w boxes