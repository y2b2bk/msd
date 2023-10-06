'reinit'

'open homedir/level_2/stps/season/variable/variable.ctl'

'set vpage 0 11 0 8.5'
'set grads off'
'set grid off'

'set parea 1 9.5 1 7'
'set xlopts 1 1 0.15'
'set ylopts 1 1 0.15'
'set mproj off'
'set lon -0.05 0.05'
'set y 1 9'
'set gxout shaded'
'set clevs levels'
'd power'
'set gxout contour'
'set clevs levels'
'set clab off'
*'d power'

'run homedir/tools/cbarn.gs 0.8 1 9.8 4'

'set string 1 c'
'set strsiz 0.25'
'draw string 5.25 8 Equatorial Space-Time Spectra'

'set strsiz 0.15'
'draw string 5.25 0.5 Frequency (cycles/day)'

'set string 1 l'
'set strsiz 0.18'
'draw string 1 7.2 title_var, title_sea without annual cycle'

'set string 1 c 1 90'
'draw string 0.3 4 Wavenumber'

*'printim variable.season.gif x770 y595 white'
'printim variable.season.png x770 y595 white'
