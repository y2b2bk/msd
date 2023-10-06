*****************************************************
*       Cross Spectrum Plot                         *
* modified by Daehyun Kim [2007/01/13]              *
*                                                   *
*   data file format : numb, freq, Coh2, Phase      *
*****************************************************
*
function main(args)
'reinit'
'clear'

if (args='') 
  say 'Input File Name:'
  pull fname
else
  fname = args
endif

* Set Title, X-legend, Min/Max, etc.
title="Coherence squared and phase bet. PC1 and PC2, title_sea"
xlab ="frequency (cycles/day)"
ylab ="Coherence squared"
ylab2 ="Phase"

* cmap = 0.05
* others = 0.005
xmin =0.005
xmax =0.061
ymin =0
ymax =1

*phase range
pmin = 0
pmax = 360

plow = 0.0
pint = 90

ylow =0.0
yint =0.2

* Set picture variables (unit:inch)

* the length of each side
* coh2
xs   = 8
ys   = 4
* phase
xs2  = 8
ys2  = 1.5

* the position of each side
* coh2
x0   =1.5
y0   =1.0
x1   =x0+xs
y1   =y0+ys
* phase
x02   = 1.5
y02   = y1
x12   = x02+xs2
y12   = y02+ys2

* for coh2
xtic =x0-0.07
ytic =y0-0.07

* for phase
xtic2 =x1+0.07

* for coh2
xlbl =x0-0.12
* for phase
xlbl2 =x1+0.12

ylbl =y0-0.12

xttl =(x0+x1)/2
yttl =y12+0.6

xxlb =(x0+x1)/2
yxlb =y0-0.6

xylb =x0-0.8
yylb =(y0+y1)/2

xylb2 =x1+0.8
yylb2 =(y02+y12)/2

* Print file open
*'enable print cntl.gx'

* Dummy operations  : It must be included !!! : Don't Delete
'open power.dummy.ctl'
'set ccolor 1'
'set parea 'x0' 'x1' 'y0' 'y12

'set frame off'
'set grid off'
'set grads off'
'set x 1'
'set y 1'
'set lev 'xmax' 'xmin
'set zlog on'
'set ylab off'
'set xlab off'
'set cmark 0'
'd   power'
* Draw frame
'set line 1 1 4'
'draw line 'x0' 'y0'  'x1' 'y0
'draw line 'x1' 'y0'  'x1' 'y12
'draw line 'x1' 'y12' 'x0' 'y12
'draw line 'x0' 'y12' 'x0' 'y0

xlg1 =logzz(xmin)
xlg2 =logzz(xmax)

'set line 1 2 1'
'set string 1 l'
'set strsiz 0.12'
  xlog=logzz(0.0125)
  xfrq1=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
'draw line 'xfrq1' 'y0' 'xfrq1' 'y12
'draw string 'xfrq1+0.1' 'y12-0.2' 80 day'
  xlog=logzz(0.033)
  xfrq2=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
'draw line 'xfrq2' 'y0' 'xfrq2' 'y12
'draw string 'xfrq2+0.1' 'y12-0.2' 30 day'

aa = read(crsp.mcoh)
bb = sublin(aa,2)
cc = subwrd(bb,1)

  ycoh=(cc-ymin)/(ymax-ymin)*ys+y0

'set string 1 r 1 0'
'set strsiz 0.15'
'draw string 'xfrq1-0.1' 'ycoh' 'cc
'set line 1 1 3'
'draw line 'xfrq1' 'ycoh' 'xfrq2' 'ycoh


* Draw y-axis tic for phase
'set string 1 l 3'
pp = plow*'1.0'
while (pp<=pmax & pp>=pmin)
  p=(pp-pmin)/(pmax-pmin)*ys2+y02
  'set line 1 1 3'
  'draw line 'x1' 'p' 'xtic2' 'p
  'draw string 'xlbl2' 'p' 'pp
  'set line 1 2 3'
  'draw line 'x0' 'p' 'x1' 'p
  pp = pp + pint
endwhile

* Draw power spectrum : freq, powr, nois
'set line 1 1 3'

first = 0
while (1)
  ret = read(fname)
  rc = sublin(ret,1)
  if (rc>0) 
    if (rc!=2) 
      say 'File I/O Error'
      return
    endif
    break
  endif
  rec = sublin(ret,2)
  ipnt= subwrd(rec,1)
  freq= subwrd(rec,2)
  coh2= subwrd(rec,3)
  phas= subwrd(rec,4)
  xlog=logzz(freq)
  xfrq=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
  ycoh=(coh2-ymin)/(ymax-ymin)*ys+y0
  ypha=(phas-pmin)/(pmax-pmin)*ys2+y02

  if (first) 
    'set line 4 1 3'
    'draw line 'xold' 'ypld' 'xfrq' 'ycoh
    'set line 2 3 3'
    'draw line 'xold' 'ynld' 'xfrq' 'ypha
  endif
  first = 1
  xold = xfrq
  ypld = ycoh
  ynld = ypha
endwhile

* Draw x-axis tic
'set line 1 1 3'
'set string 1 tc 3'
'set strsiz 0.15 0.15'

xlow =0.0001
xx = xlow*'1.0'
while (xx<1)
  if (xx<=xmax & xx>=xmin)
    xlog=logzz(xx)
    x=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
    'draw line 'x' 'y0' 'x' 'ytic
    'draw string 'x' 'ylbl' 'xx
  endif
  ii=2
  xx2=xx*ii
  while ii<10
    if (xx2<xmax & xx2>xmin)
      xlog=logzz(xx2)
      x=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
      'draw line 'x' 'y0' 'x' 'ytic
    endif
    ii=ii+1
    xx2=xx*ii
  endwhile
  xx = xx*'10.0'
endwhile

* Draw y-axis tic for coh2
'set string 1 r 3'
yy = ylow*'1.0'
while (yy<=ymax & yy>=ymin)
  y=(yy-ymin)/(ymax-ymin)*ys+y0
  'draw line 'x0' 'y' 'xtic' 'y
  'draw string 'xlbl' 'y' 'yy
  yy = yy + yint
endwhile


* Draw Title
'set string 1 c 3'
'set strsiz 0.20'

'draw string 'xttl' 'yttl' 'title
'set strsiz 0.20'
'draw string 'xxlb' 'yxlb' 'xlab

'set string 1 c 3 90'
'draw string 'xylb' 'yylb' 'ylab
'draw string 'xylb2' 'yylb2' 'ylab2


* Print file
*'printim 'fname'.gif gif x770 y595 white'
'printim 'fname'.png x770 y595 white'
*'disable print'

* User Defined Function
function logzz(freq)
  one=1.
  'q w2xy 'one' 'freq
  x=subwrd(result,3)
  y=subwrd(result,6)
return y
