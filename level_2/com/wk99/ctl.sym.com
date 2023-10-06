dset ^seg96_over60_sym.gdat
undef missing
options 365_day_calendar
title  NCEP/NCAR ReANL PROJECT: CDAS: Monthly Means and Anom(using 79-95 clim)
xdef   num_x linear  beg_x  int_x
ydef   sel_y linear  beg_y  int_y
zdef   num_s linear 1 1
tdef  1000 linear   01jan1979   1dy
vars 1 
p  num_s 99 OLR 
endvars
