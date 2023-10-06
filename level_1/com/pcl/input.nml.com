 &dimension_nml
  imax = 1, jmax = 1, kmax = 1, 
  ksel = 1, vmax = 1, rmax = 1, smax = 1, 
  dmax = num_d, tmax = num_t, filt_wing = 0,
  ymax = num_r, 
  season = sea_num, year1 = beg_year,
  leap = leap_year, linux = linux_recl,
  fac1 = sign1, fac2 = sign2/

 &region_nml
  isel = 1, jsel = 1, ip = 1, jp = 1,
  ilon = 0.0, dlon = 2.5, jlat = 0.0, dlat = 2.5 /

 &lag_nml
  lag_time = 30 /

 &filename_nml
  inname1 = 'homedir/level_1/variable/eof/sea_name/eof.ts',
  outname = 'homedir/level_1/variable/eof/sea_name/pcl'/

 &dmiss_nml
  dmiss = missing/
