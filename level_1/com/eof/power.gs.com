*****************************************************
*       Power Spectrum Plot                         *
*                                                   *
*   data file format : numb, freq, power, noise     *
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
title="MODEnumber, title_var, title_sea"
xlab ="frequency (cycles/day)"
ylab ="power x frequency"

* cmap = 0.05
* others = 0.005
xmin =0.005
xmax =0.51
ymin =0
ymax =y_ran

ylow =0.0
yint =y_int

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

* Print file open
*'enable print cntl.gx'

* Dummy operations  : It must be included !!! : Don't Delete
'open power.dummy.ctl'
'set ccolor 1'
'set parea 'x0' 'x1' 'y0' 'y1

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
'draw line 'x0' 'y0' 'x1' 'y0
'draw line 'x1' 'y0' 'x1' 'y1
'draw line 'x1' 'y1' 'x0' 'y1
'draw line 'x0' 'y1' 'x0' 'y0

* Draw power spectrum : freq, powr, nois

'set line 1 1 3'

xlg1 =logzz(xmin)
xlg2 =logzz(xmax)

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
  powr= subwrd(rec,3)
  nois= subwrd(rec,4)
  xlog=logzz(freq)
  xfrq=(xlog-xlg1)/(xlg2-xlg1)*xs+x0
  ypow=(powr-ymin)/(ymax-ymin)*ys+y0
  ynos=(nois-ymin)/(ymax-ymin)*ys+y0
  ynos90=(nois*1.26-ymin)/(ymax-ymin)*ys+y0
  ynos95=(nois*1.35-ymin)/(ymax-ymin)*ys+y0

  if (first) 
    'set line 4 1 3'
    'draw line 'xold' 'ypld' 'xfrq' 'ypow
    'set line 2 3 3'
    'draw line 'xold' 'ynld' 'xfrq' 'ynos
    'set line 2 3 3'
    'draw line 'xold' 'yn90ld' 'xfrq' 'ynos90
    'set line 2 3 3'
    'draw line 'xold' 'yn95ld' 'xfrq' 'ynos95
  endif
  first = 1
  xold = xfrq
  ypld = ypow
  ynld = ynos
  yn90ld = ynos90
  yn95ld = ynos95
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

* Draw y-axis tic
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

* Print file
*'printim 'fname'.season.gif gif x1100 y850 white'
*'printim 'fname'.season.gif gif x770 y595 white'
'printim 'fname'.season.png x770 y595 white'
*'disable print'

* User Defined Function
function logzz(freq)
  one=1.
  'q w2xy 'one' 'freq
  x=subwrd(result,3)
  y=subwrd(result,6)
return y
