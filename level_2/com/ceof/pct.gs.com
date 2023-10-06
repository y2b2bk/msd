'reinit'

'open ceof.pct.ctl'

* Set picture variables (unit:inch)
xs   = 9
ys   = 6
x0   =1.5
y0   =1.0
x1   =x0+xs
y1   =y0+ys
xtic =x0-0.07
ytic =y0-0.07
xlbl =x0-0.12
ylbl =y0-0.12
xttl =(x0+x1)/2
yttl =y1+0.6
xxlb =(x0+x1)/2
yxlb =y0-0.6
xylb =x0-1.2
yylb =(y0+y1)/2

'set parea 'x0' 'x1' 'y0' 'y1
'set grads off'
'set grid off'
'set vrange 0 25'
'set xlopts 1 1 0.15'
'set ylopts 1 1 0.15'
'set ylint 3'
'set x 0.5 10.5'
'set xaxis 0.5 10.5 1'
'set gxout bar'
'set bargap 50'
'set ccolor 4'
'd pct'

* Draw Title
'set string 1 c 3'
'set strsiz 0.20'

'draw string 'xttl' 'yttl' Percentage variance, title_var, title_sea'
'set strsiz 0.20'
'draw string 'xxlb' 'yxlb' Mode'

'set string 1 c 3 90'
'draw string 'xylb' 'yylb' Percentage(%)'

* Print file
*'printim pct.gif gif x770 y595 white'
'printim pct.png x770 y595 white'
*'disable print'
