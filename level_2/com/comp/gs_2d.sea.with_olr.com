'reinit'

uu = option 

'run homedir/tools/blue_red.gs'
'open homedir/level_2/comp/variable/comp.season.ctl'
'open homedir/level_2/comp/variable/n_comp.season.ctl'
'open homedir/level_2/comp/olr_name/comp.season.ctl'

p1 = 1
p2 = 8
while (p1<=p2)
'set vpage 0 8.5 0 11'
'set grads off'
'set grid off'
'set parea 0.5 7.5 '9.3-1.2*(p1-1)' '10.3-1.2*(p1-1)
'set xlab off'
if (p1=8)
'set xlab on'
endif
'set ylint 15'
'set dfile 1'
'set lat -20 20'
'set z 1'
'set t 'p1
'set gxout shaded'
'set clevs levels'
'set ccols colors'
'd factor*p'
'set dfile 3'
'set lat -20 20'
'set z 1'
'set t 'p1
'set gxout contour'
'set ccolor 1'
'set clab off'
*'set clevs -24 -21 -18 -15 -12 -9 -6 -3 3 6 9 12 15 18 21 24'
'set clevs -25 -20 -15 -10 -5'
'set ccolor 9'
'set cthick 10'
'd p'
'set clevs 5 10 15 20 25'
'set ccolor 3'
'set cthick 10'
'd p'
p1 = p1 + 1
endwhile

'set string 1 c'
'set strsiz 0.15'
'draw string 4.25 10.8 MJO Life cycle composite'

'set string 1 l'
'set strsiz 0.12'
'draw string 0.5 10.4 title_mjo (title_var, shaded) & OLR (title_var, contour)'
'set string 1 r'
'draw string 7.5 10.4 title_sea'

'set string 1 l'
'set strsiz 0.11'
p1 = 1
p2 = 8
while (p1<=p2)
'set dfile 2'
'set x 1'
'set y 1'
'set z 1'
'set t 'p1
'd n.2'
ndy=subwrd(result,4)

'draw string 7.6 '10.2-1.2*(p1-1)' Phase 'p1
'draw string 7.6 '10.0-1.2*(p1-1)' 'ndy' days'
p1 = p1 + 1
endwhile

'set string 1 l'
'set strsiz 0.1'

if (uu=1)
*'draw string 6.7 0.25 Unit : [unit1]'
'draw string 6.7 0.55 Unit : [unit1]'
endif
if (uu=2)
*'draw string 6.7 0.25 Unit : [unit1`aorder1`n]'
'draw string 6.7 0.55 Unit : [unit1`aorder1`n]'
endif

'run homedir/tools/cbar-g3.gs 1 2 0 4.0 0.3 1 5 0.7'

'printim comp.vname.season.gif gif x595 y770 white'
