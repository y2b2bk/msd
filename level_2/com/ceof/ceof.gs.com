'reinit'

order = mode_order

ret = read(ceof.var)
std = sublin(ret,2)
olrs = subwrd(std,1)
u85s = subwrd(std,2)
u20s = subwrd(std,3)

ret = read(ceof.pct)
percent = sublin(ret,2)
pct1 = subwrd(percent,1)
pct2 = subwrd(percent,2)

ret = read(ceof.pct.olr)
percent = sublin(ret,2)
olr1 = subwrd(percent,1)
olr2 = subwrd(percent,2)

ret = read(ceof.pct.u850)
percent = sublin(ret,2)
u851 = subwrd(percent,1)
u852 = subwrd(percent,2)

ret = read(ceof.pct.u200)
percent = sublin(ret,2)
u201 = subwrd(percent,1)
u202 = subwrd(percent,2)

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

'open homedir/level_2/ceof/ts.ctl'
nm1 = 1
nm2 = 2
while (nm1 <= nm2)

 z1 = 1
 z2 = 3
 while(z1 <= z2)
'set z 'z1
'define aa = tloop(ave(ts'nm1',t=1,t=n_time))'
'define bb = tloop(ave(pow(ts'nm1'-aa,2),t=1,t=n_time))'
'define s'nm1'z'z1' = sqrt(bb)'

 z1 = z1 + 1
 endwhile

nm1 = nm1 + 1
endwhile

'close 1'

'open homedir/level_2/ceof/ev.ctl'
'set z 1'
'define zero = ev1*0'
'set vpage 0 8.5 0 11'
'set grads off'
'set vrange -1.5 1.5'
'set ylint 0.2'
if (order=1)
'set parea 1 8 7 10'
endif
if (order=2)
'set parea 1 8 2.5 5.5'
endif
'set gxout contour'
'set ccolor 1'
'set cmark 0'
'set cthick 1'
'd zero'
'set z 1'
'set ccolor 1'
'set cmark 0'
'set cthick 7'
'd e1*s1z1'
'set z 2'
'set ccolor 2'
'set cmark 0'
'set cthick 7'
'd e1*s1z2'
'set z 3'
'set ccolor 3'
'set cmark 0'
'set cthick 7'
'd e1*s1z3'

'set vpage 0 8.5 0 11'
'set grads off'
'set vrange -1.5 1.5'
'set ylint 0.2'
if (order=2)
'set parea 1 8 7 10'
endif
if (order=1)
'set parea 1 8 2.5 5.5'
endif
'set gxout contour'
'set ccolor 1'
'set cmark 0'
'set cthick 1'
'd zero'
'set z 1'
'set ccolor 1'
'set cmark 0'
'set cthick 7'
'd e2*s2z1'
'set z 2'
'set ccolor 2'
'set cmark 0'
'set cthick 7'
'd e2*s2z2'
'set z 3'
'set ccolor 3'
'set cmark 0'
'set cthick 7'
'd e2*s2z3'

'set string 1 c'
'set strsiz 0.2'
'draw string 4.5 10.6 title_var, title_sea, period'

'set string 1 l'
'set strsiz 0.15'


 if (order=1)
'draw string 1 10.15 a) 1st mode ('pct1'%)'
'draw string 1 05.65 b) 2nd mode ('pct2'%)'
'set string 1 l 1 0'
'set strsiz 0.12'
'draw string 1 6.2 Variance accounted for: OLR='olr1'%; u850='u851'%; u200='u201'%'
'draw string 1 1.7 Variance accounted for: OLR='olr2'%; u850='u852'%; u200='u202'%'
 endif

 if (order=2) 
'draw string 1 10.15 a) 2nd mode ('pct2'%)'
'draw string 1 05.65 b) 1st mode ('pct1'%)'
'set string 1 l 1 0'
'set strsiz 0.12'
'draw string 1 6.2 Variance accounted for: OLR='olr2'%; u850='u852'%; u200='u202'%'
'draw string 1 1.7 Variance accounted for: OLR='olr1'%; u850='u851'%; u200='u201'%'
 endif

'set line 1 1 7'
'draw line 1 1 2 1'
'set line 2 1 7'
'draw line 3.5 1 4.5 1'
'set line 3 1 7'
'draw line 6 1 7 1'

'set string 1 l'
'set strsiz 0.15'
'draw string 2.2 1 OLR'
'set strsiz 0.12'
'draw string 1.0 0.7 STD : 'olrs' [Wm`a-2`n]'
'set string 1 l'
'set strsiz 0.15'
'draw string 4.7 1 U850'
'set strsiz 0.12'
'draw string 3.5 0.7 STD : 'u85s' [ms`a-1`n]'
'set string 1 l'
'set strsiz 0.15'
'draw string 7.2 1 U200'
'set strsiz 0.12'
'draw string 6.0 0.7 STD : 'u20s' [ms`a-1`n]'

'set string 1 r'
'set strsiz 0.13'
'draw string 8 0.3 Reference : Wheeler and Hendon (2006)'

'set string 1 c'
'set strsiz 0.15'
'draw string 4.5 6.6 Longitude (Deg)'
'draw string 4.5 2.1 Longitude (Deg)'
'set string 1 c 1 90'
'set strsiz 0.15'
'draw string 0.2 8.5 Normalized Amplitude'
'draw string 0.2 4.0 Normalized Amplitude'


*'printim ceof.gif gif x850 y1100 white'
'printim ceof.png x850 y1100 white'
