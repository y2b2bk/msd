'reinit'

'set rgb 32   0   0  60'
'set rgb 33   0   0 120'
'set rgb 34   0   0 180'
'set rgb 35   0  30 255'
'set rgb 36  40  90 255'
'set rgb 37  80 120 255'
'set rgb 38 120 180 255'
'set rgb 39 160 210 255'
'set rgb 40 200 240 255'
'set rgb 41 255 240 200'
'set rgb 42 255 210 160'
'set rgb 43 255 180 120'
'set rgb 44 255 120  80'
'set rgb 45 255  90  40'
'set rgb 46 255  30   0'
'set rgb 47 180   0   0'
'set rgb 48 120   0   0'
'set rgb 49  60   0   0'

'open homedir/level_1/variable/lgc/experiment.llreg_2d.ctl'

'set vpage 0 11 0 8.5'
'set grads off'
'set parea 1.5 10.5 2 7'
'set lat -40 40'
'set xlopts 1 1 0.15'
'set ylopts 1 1 0.15'
'set yaxis -25 25 5'
'set t 1 51'
'set gxout shaded'
'set clevs -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8'
'set ccols 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49'
'define aa = abs(cor)*sqrt(dof-2)/sqrt(1-cor*cor)'
* 99% 2.576
* 95% 1.960
* 90% 1.645
'd maskout(cor,aa-2.576)' 
'set gxout contour'
'set cint 0.1'
'set black -0.01 0.01'
'd cor'

'run homedir/tools/cbarn.gs 1.0 0 6.0 0.8'

'set string 1 c'
'set strsiz 0.20'
'draw string 6.0 8.0 Lag correlation'
'set strsiz 0.15'
'draw string 6.0 7.5 title_var, title_sea'

'set strsiz 0.20'
'draw string 6.0 1.5 Latitude (Deg)'
'set strsiz 0.15'
'draw string 8.7 1.3 Shading : 99% sig.'

'set string 1 c 1 90'
'set strsiz 0.20'
'draw string 0.7 4.5 Lag (Day)'

*'printim experiment.gif gif x1100 y850 white'
'printim experiment.png x1100 y850 white'
