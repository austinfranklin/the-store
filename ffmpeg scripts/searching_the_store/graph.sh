# graph
set boxwidth 0.7
set style fill solid 1.0
set yrange[0:]
# use line number for x coordinate, column 1 for tic label
plot ".graph_file.txt" u 2:xtic(1) w boxes