 'reinit'

 'open homedir/level_1/variable/data/daily.anom.period.ctl'

 'set x 1'
 'set y 1'
 'set z 1'
 'set t 1 num_t'

 'set fwrite homedir/level_1/variable/data/region.season.series'
 'set gxout fwrite'
 'define aa= aave(p,lon=beg_lon,lon=end_lon,lat=beg_lat,lat=end_lat)'
 'd aa'
 'disable fwrite'
