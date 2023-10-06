 &dimension_nml
  imax = num_x, jmax = num_y, kmax = 1, 
  ksel = 1, vmax = 1, rmax = 1, smax = 1, 
  dmax = num_d, tmax = num_t, filt_wing = 100,
  ymax = num_r,
  season = sea_num, year1 = beg_year,
  leap = leap_year, linux = linux_recl/

 &region_nml
  isel = num_x, jsel = num_y, ip = 1, jp = 1,
  ilon = beg_lon, dlon = del_lon, jlat = beg_lat, dlat = del_lat /

 &lag_nml
  lag_time = 25 /

 &filename_nml
  inname1 = 'homedir/level_1/variable/data/daily.filt.20-100.lanz.100.zm.period.gdat',
  inname2 = 'homedir/level_1/variable/data/in_name.series',
  outname = 'homedir/level_1/variable/lgc/out_name'/

 &dmiss_nml
  dmiss = missing/
