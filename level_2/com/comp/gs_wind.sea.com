'reinit'

uu = option 

'run homedir/tools/blue_red.gs'
'open homedir/level_2/comp/olr_name/comp.season.ctl'
'open homedir/level_2/comp/u_name/comp.season.ctl'
'open homedir/level_2/comp/v_name/comp.season.ctl'
'open homedir/level_2/comp/olr_name/n_comp.season.ctl'

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
'set lat -20 20'
'set t 'p1
'set gxout shaded'
'set clevs -24 -21 -18 -15 -12 -9 -6 -3 3 6 9 12 15 18 21 24'
'set ccols 33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
'd p'
'set gxout vector'
'set arrlab off'
'set arrowhead ahhh'
'set arrscl 0.3 asss'
'd skip(p.2,2,2);p.3'
p1 = p1 + 1
endwhile

'set string 1 c'
'set strsiz 0.15'
'draw string 4.25 10.8 MJO Life cycle composite'

'set string 1 l'
'set strsiz 0.12'
'draw string 0.5 10.4 title_mjo wind (title_var) and OLR (title_var)'
'set string 1 r'
'draw string 7.5 10.4 title_sea'

'set string 1 l'
'set strsiz 0.11'
p1 = 1
p2 = 8
while (p1<=p2)
'set dfile 4'
'set x 1'
'set y 1'
'set t 'p1
'd n'
ndy=subwrd(result,4)

'draw string 7.6 '10.2-1.2*(p1-1)' Phase 'p1
'draw string 7.6 '10.0-1.2*(p1-1)' 'ndy' days'
p1 = p1 + 1
endwhile

'set string 1 l'
'set strsiz 0.1'

'draw string 6.7 0.25 Unit : [W m`a-1`n]'

'run homedir/tools/cbarn.gs 0.7 0 4.25 0.3'

'printim comp.lll_wind.season.gif gif x595 y770 white'
