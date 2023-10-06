dset ^daily.5x5.filt.20-100.lanz.100.period.gdat
undef missing
xdef sel_x linear     0.0  5.00
ydef sel_y linear sel_lat  5.00
zdef     1 levels 1000
tdef num_t linear 01jan1979 1dy
vars 1 
p  1 1 interpolated, filtered anomaly
endvars
