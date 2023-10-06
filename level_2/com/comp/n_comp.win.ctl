dset ^n_comp.win.gdat
*options 365_day_calendar
undef -999.
title  NCEP/NCAR ReANL PROJECT: CDAS: Monthly Means and Anom(using 79-95 clim)
xdef     1 linear    0.000  2.500
ydef     1 linear    0.000  2.500
zdef     1 levels 1000
tdef     8 linear   01jan1979   1dy
vars 1 
n  1 99 OLR 
endvars
