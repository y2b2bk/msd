dset ^daily.filt.20-100.lanz.100.zm.period.gdat
undef missing
xdef  num_x linear  beg_lon  del_lon
ydef  num_y linear  beg_lat  del_lat
zdef     1 levels 1000
tdef  num_t linear   01jan1979   1dy
vars 1 
p  1 1 var
endvars
