 'reinit'

 'run homedir/tools/GYR-01.gs'

 'open homedir/level_1/variable/var/raw.season.ctl'
 'open homedir/level_1/variable/var/fil.season.ctl'

 'set vpage 0 8.5 0 11'

 'set lat -30 30'
 'set ylint 20'
 'set grads off'

 'set parea 0.5 8 8 10.5'
 'set gxout shaded'
 'set clevs levels_tot'
 'set ccols 0 30 35 40 50 55 60 65 70 75'
 'd (v.1)'
 'run homedir/tools/cbarn.gs 0.7 0 4.25 7.8'

 'set parea 0.5 8 4.5 7.0'
 'set gxout shaded'
 'set clevs levels_fil'
 'set ccols 0 30 35 40 50 55 60 65 70 75'
 'd (v.2)'
 'run homedir/tools/cbarn.gs 0.7 0 4.25 4.3'

 'set parea 0.5 8 1.0 3.5'
 'set gxout shaded'
 'set clevs 10 15 20 25 30 35 40 45 50'
 'set ccols 0 30 35 40 50 55 60 65 70 75'
 'd (v.2/v.1)*100'
 'run homedir/tools/cbarn.gs 0.7 0 4.25 0.8'

 'set string 1 l'
 'set strsiz 0.15'

 'draw string 0.5 10.4 (a) Unfiltered variance, title_mjo, title_var, title_sea'
 'draw string 0.5 6.9 (b) 20-100 day variance, title_mjo, title_var, title_sea'
 'draw string 0.5 3.4 (c) % of Unfiltered variance, title_mjo, title_var, title_sea'

 'set strsiz 0.12'
 'draw string 6.5 7.7 Unit : [unit1`a-order1`n]`a2`n'
 'draw string 6.5 4.2 Unit : [unit1`a-order1`n]`a2`n'

* 'printim season.gif gif x850 y1100 white'
 'printim season.eps eps x850 y1100 white'
