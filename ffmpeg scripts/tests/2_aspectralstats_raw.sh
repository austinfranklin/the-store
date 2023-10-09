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