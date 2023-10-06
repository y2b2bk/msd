dset ^data.season.gdat
undef missing
xdef  num_x linear  beg_lon  del_lon
ydef  num_y linear  beg_lat  del_lat
zdef      1 levels 1000
tdef      1 linear   01jan1979   1dy
vars 1 
v     1   1  variance
endvars
