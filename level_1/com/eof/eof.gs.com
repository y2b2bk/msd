'reinit'

ret = read(eof.pct)
percent = sublin(ret,2)
pct1 = subwrd(percent,1)
pct2 = subwrd(percent,2)
pct3 = subwrd(percent,3)
pct4 = subwrd(percent,4)

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

'open homedir/level_1/variable/eof/season/ts.ctl'
nm1 = 1
nm2 = 4
while (nm1 <= nm2)
'define aa = tloop(ave(ts'nm1',t=1,t=n_time))'
'define bb = tloop(ave(pow(ts'nm1'-aa,2),t=1,t=n_time))'
'define sig'nm1' = sqrt(bb)'
nm1 = nm1 + 1
endwhile
'close 1'

'open homedir/level_1/variable/eof/season/ev.ctl'
'set vpage 0 8.5 0 11'
'set grads off'
'set ylint 10'
'set parea 1 8 8.5 10'
'set gxout shaded'
'set clevs levels'
'set ccols 32 33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48 49'
'd ppe1*sig1'
'set gxout contour'
'set black -0.1 0.1'
'set ccolor 1'
'set cint c_int'
'd ppe1*sig1'
'set vpage 0 8.5 0 11'
'set grads off'
'set ylint 10'
'set parea 1 8 6.5 8.0'
'set gxout shaded'
'set clevs levels'
'set ccols 32 33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48 49'
'd ppe2*sig2'
'set gxout contour'
'set black -0.1 0.1'
'set ccolor 1'
'set cint c_int'
'd ppe2*sig2'
'set vpage 0 8.5 0 11'
'set grads off'
'set ylint 10'
'set parea 1 8 4.5 6.0'
'set gxout shaded'
'set clevs levels'
'set ccols 32 33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48 49'
'd ppe3*sig3'
'set gxout contour'
'set black -0.1 0.1'
'set ccolor 1'
'set cint c_int'
'd ppe3*sig3'
'set vpage 0 8.5 0 11'
'set grads off'
'set ylint 10'
'set parea 1 8 2.5 4.0'
'set gxout shaded'
'set clevs levels'
'set ccols 32 33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48 49'
'd ppe4*sig4'
'set gxout contour'
'set black -0.1 0.1'
'set ccolor 1'
'set cint c_int'
'd ppe4*sig4'

*'run homedir/tools/cbarn.gs 1.0 0 4.5 1.7'
'run homedir/tools/cbar-g3.gs 1 2 0 4.25 1.5 1 5 0.7'

'set string 1 c'
'set strsiz 0.2'
'draw string 4.5 10.6 title_var, EOFs 1-4, title_sea'

'set string 1 l'
'set strsiz 0.15'

 order = mode_order

 if (order=1)
'draw string 1 10.15 a) 1st mode ('pct1'%)'
'draw string 1 08.15 b) 2nd mode ('pct2'%)'
'draw string 1 06.15 c) 3rd mode ('pct3'%)'
'draw string 1 04.15 d) 4th mode ('pct4'%)'
 endif

 if (order=2) 
'draw string 1 10.15 a) 2nd mode ('pct2'%)'
'draw string 1 08.15 b) 1st mode ('pct1'%)'
'draw string 1 06.15 c) 3rd mode ('pct3'%)'
'draw string 1 04.15 d) 4th mode ('pct4'%)'
 endif

 if (order=3)
'draw string 1 10.15 a) 1st mode ('pct1'%)'
'draw string 1 08.15 b) 2nd mode ('pct2'%)'
'draw string 1 06.15 c) 4th mode ('pct4'%)'
'draw string 1 04.15 d) 3rd mode ('pct3'%)'
 endif

'set string 1 c'
'set strsiz 0.15'
'draw string 4.5 2.2 Longitude (Deg)'
'set string 1 c 1 90'
'set strsiz 0.15'
'draw string 0.2 6.25 Latitude (Deg)'

*'printim eof.season.gif gif x850 y1100 white'
'printim eof.season.png x850 y1100 white'
