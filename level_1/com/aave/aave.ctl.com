dset ^region.season.series
undef missing
xdef     1 linear 0.0 1.0
ydef     1 linear 0.0 1.0
zdef     1 levels 1000
tdef num_t linear 01jan1979  1dy
vars 1 
p     1   1  variance
endvars
