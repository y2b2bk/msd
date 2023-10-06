'reinit'

uu = option

'run homedir/tools/blue_red.gs'
'open homedir/level_2/comp/olr_name/comp.season.ctl'
'open homedir/level_2/comp/variable/comp.season.ctl'
'open homedir/level_2/comp/olr_name/n_comp.season.ctl'

p1 = 1
p2 = 4
while (p1<=p2)
'set vpage 0 11 0 8.5'
'set grads off'
'set grid off'
'set parea '0.5+2.5*(p1-1)' '2.5+2.5*(p1-1)' 5.5 7.5'
'set dfile 2'
'set lat 0'
'set z 1 ztop'
'set t 'p1
'set xlab off'
'set ylint 100'
'set gxout shaded'
'set clevs levels'
'set ccols colors'
if (uu=3)
'd p.2*1000'
else
'd p.2'
endif
'set gxout contour'
'set clevs levels'
'set clab off'
if (uu=3)
'd p.2*1000'
else
'd p.2'
endif
'set clevs 0'
'set clab off'
'd p.2'
'set parea '0.5+2.5*(p1-1)' '2.5+2.5*(p1-1)' 4.5 5.2'
'set dfile 1'
'set lat 0'
'set z 1'
'set t 'p1
'set vrange -30 30'
'set ylevs -20 0 20'
'set xlab on'
'set ccolor 1'
'set cmark 0'
'd p.1*0'
'set ccolor 9'
'set cmark 0'
'd ave(p.1,lat=-5,lat=5)'
p1 = p1 + 1
endwhile

p1 = 5
p2 = 8
while (p1<=p2)
'set vpage 0 11 0 8.5'
'set grads off'
'set grid off'
'set parea '0.5+2.5*(p1-5)' '2.5+2.5*(p1-5)' 1.5 3.5'
'set dfile 2'
'set lat 0'
'set z 1 ztop'
'set t 'p1
'set xlab off'
'set ylint 100'
'set gxout shaded'
'set clevs levels'
'set ccols colors'
if (uu=3)
'd p.2*1000'
else
'd p.2'
endif
'set gxout contour'
'set clevs levels'
'set clab off'
if (uu=3)
'd p.2*1000'
else
'd p.2'
endif
'set clevs 0'
'set clab off'
'd p.2'
'set parea '0.5+2.5*(p1-5)' '2.5+2.5*(p1-5)' 0.5 1.2'
'set dfile 1'
'set lat 0'
'set z 1'
'set t 'p1
'set xlab on'
'set vrange -30 30'
'set ylevs -20 0 20'
'set ccolor 1'
'set cmark 0'
'd p.1*0'
'set ccolor 9'
'set cmark 0'
'd ave(p.1,lat=-5,lat=5)'
p1 = p1 + 1
endwhile

'set string 1 c'
'set strsiz 0.15'
'draw string 5.5 8.3 MJO Life cycle composite'

'set string 1 l'
'set strsiz 0.12'
'draw string 0.5 8.0 title_mjo (5N-5S, title_var)'
'set string 1 r'
'draw string 10 8.0 title_sea'

p1 = 1
p2 = 4
while (p1<=p2)
'set dfile 3'
'set x 1'
'set y 1'
'set t 'p1
'd n'
ndy=subwrd(result,4)
'set string 1 l'
'set strsiz 0.10'
'draw string '0.5+2.5*(p1-1)' 7.7 Phase 'p1': 'ndy' days'
'draw string '0.5+2.5*(p1-1)' 5.3 OLR anomaly [Wm`a-2`n]'
p1 = p1 + 1
endwhile

p1 = 5
p2 = 8
while (p1<=p2)
'set dfile 3'
'set x 1'
'set y 1'
'set t 'p1
'd n'
ndy=subwrd(result,4)
'set string 1 l'
'set strsiz 0.10'
'draw string '0.5+2.5*(p1-5)' 3.7 Phase 'p1': 'ndy' days'
'draw string '0.5+2.5*(p1-5)' 1.3 OLR anomaly [Wm`a-2`n]'
p1 = p1 + 1
endwhile

'set string 1 l'
'set strsiz 0.1'

if (uu=1)
'draw string 10.3 7.5 [unit1`aorder1`n]'
'draw string 10.3 3.5 [unit1`aorder1`n]'
endif
if (uu=2)
'draw string 10.3 7.8 [unit1]'
'draw string 10.3 3.8 [unit1]'
endif
if (uu=3)
'draw string 10.3 7.5 [unit1`aorder1`n]'
'draw string 10.3 3.5 [unit1`aorder1`n]'
endif
if (uu=4)
'draw string 10.3 7.8 [unit1`aorder1`n]'
'draw string 10.3 3.8 [unit1`aorder1`n]'
endif

'run homedir/tools/cbarn.gs 0.5 1 10.4 6'
'run homedir/tools/cbarn.gs 0.5 1 10.4 2'

'printim comp.vname.season.gif gif x990 y765 white'
