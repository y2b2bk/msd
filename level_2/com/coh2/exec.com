reinit
*
open homedir/level_2/coh2/variable/power/sym.coh2.ctl
open homedir/level_2/coh2/variable/power/asy.coh2.ctl
*enable print variable.gmf
*
set xlopts 1 2 0.10
set ylopts 1 2 0.10
*
*****************************************************************
**************  SYMM  *******************************************
*****************************************************************
run homedir/tools/BYR-03
set vpage 0 11 0 8.5
*set parea 0.8 3.6 4.55 7.3
set parea 1 5 1.5 6.5
set grads off
set clopts 1 1 0.05
set grads off
set grid off
set lon -15 15
*set lat 0.01 0.5
set lat 0.008 0.5
set ylab %.2f
set mproj off
set gxout grfill
*set csmooth on
run homedir/tools/setclevs.gs 0.04 10 0.04
set ccols 0 14 4 5 13 3 10 7 8 2 6
d coh2.1
run homedir/tools/cbar-g3.gs 1 2 2 3.0 0.7 2 5 0.7
set gxout vector
set arrlab off
set arrscl 0.15 1
d skip(maskout(v1.1,abs(v1.1)-0.00001),0,2);v2.1
*
set string 1 r 6
set strsiz 0.11
*draw string 5.0 1.25 log`b10`n[mm day`a-1`n]`a2`n
set gxout contour
set clab off
*
set ylopts 1 2 0.10
set grid on
set xlab off
set ylpos 0 r
set ylevs 0.0125
set ylab 80
set clevs 5
d coh2.1
set ylab 30
set ylevs 0.033
set clevs 5
d coh2.1
set ylab 20
set ylevs 0.05
set clevs 5
d coh2.1
set ylab 15
set ylevs 0.0667
set clevs 5
d coh2.1
set ylevs 0.1
set ylab 10
set clevs 5
d coh2.1
set ylevs 0.143
set ylab 7
set clevs 5
d coh2.1
set ylevs 0.2
set ylab 5
set clevs 5
d coh2.1
set ylevs 0.25
set ylab 4
set clevs 5
d coh2.1
set ylab 3
set ylevs 0.3333
set clevs 5
d coh2.1
set ylab 2
set ylevs 0.5
set clevs 5
d coh2.1
*****************************************************************
**************  ASYM  *******************************************
*****************************************************************

set vpage 0 11 0 8.5
set parea 6.0 10.0 1.5 6.5
set xlab on
set ylab on
set grads off
set clopts 1 1 0.05
set grads off
set grid off
set lon -15 15
*set lat 0.01 0.5
set lat 0.008 0.5
set ylab %.2f
set mproj off
set gxout grfill
*set csmooth on
run homedir/tools/setclevs.gs 0.04 10 0.04
set ccols 0 14 4 5 13 3 10 7 8 2 6
d coh2.2
run homedir/tools/cbar-g3.gs 1 2 2 8.0 0.7 2 5 0.7
set gxout vector
set arrlab off
set arrscl 0.15 1
d skip(maskout(v1.2,abs(v1.2)-0.00001),0,2);v2.2
*
set string 1 r 6
set strsiz 0.11
*draw string 5.0 1.25 log`b10`n[mm day`a-1`n]`a2`n
set gxout contour
set clab off
*
set ylopts 1 2 0.10
set grid on
set xlab off
set ylpos 0 r
set ylevs 0.0125
set ylab 80
set clevs 5
d coh2.2
set ylab 30
set ylevs 0.033
set clevs 5
d coh2.2
set ylab 20
set ylevs 0.05
set clevs 5
d coh2.2
set ylab 15
set ylevs 0.0667
set clevs 5
d coh2.2
set ylevs 0.1
set ylab 10
set clevs 5
d coh2.2
set ylevs 0.143
set ylab 7
set clevs 5
d coh2.2
set ylevs 0.2
set ylab 5
set clevs 5
d coh2.2
set ylevs 0.25
set ylab 4
set clevs 5
d coh2.2
set ylab 3
set ylevs 0.3333
set clevs 5
d coh2.2
set ylab 2
set ylevs 0.5
set clevs 5
d coh2.2

*zero line
set line 1 3 0.5
draw line 3.0 1.5 3.0 6.5
draw line 8.0 1.5 8.0 6.5
*
open homedir/tools/space-time/dispers/kelvin.ctl
set dfile 3
set t 1
set vpage 0 11 0 8.5
set grads off
set parea 0.8 3.6 4.55 7.3
set parea 1 5 1.5 6.5
set xlopts 1 7 0.0
set ylopts 1 7 0.0
set lon -15 15
set y 1
set ylab off
*set axlim 0.01 0.5
set axlim 0.008 0.5
set cmark 0
set ccolor 2
set z 1
d kelvin
set cmark 0
set ccolor 2
set z 2
d kelvin
set cmark 0
set ccolor 2
set z 3
d kelvin
run homedir/tools/space-time/draw_string2.gs  9 0.15 1 0.12 Kelvin
run homedir/tools/space-time/draw_string.gs 13.5 0.31 2 0.08 12
run homedir/tools/space-time/draw_string.gs 11.5 0.37 2 0.08 25 
run homedir/tools/space-time/draw_string.gs 9.5 0.42 2 0.08 50
*
open homedir/tools/space-time/dispers/er.ctl
set dfile 4
set t 1
set vpage 0 11 0 8.5
set grads off
set parea 0.8 3.6 4.55 7.3
set parea 1 5 1.5 6.5
set xlopts 1 7 0.11
set ylopts 1 7 0.11
set lon -15 15
set y 1
*set axlim 0.01 0.5
set axlim 0.008 0.5
set cmark 0
set ccolor 2
set z 1
d er
set cmark 0
set ccolor 2
set z 2
d er
set cmark 0
set ccolor 2
set z 3
d er
run homedir/tools/space-time/draw_string2.gs -10.5 0.12 1 0.12 n=1 ER
run homedir/tools/space-time/draw_string.gs -13 0.065 2 0.08 12
run homedir/tools/space-time/draw_string.gs -13 0.075 2 0.08 25
run homedir/tools/space-time/draw_string.gs -13 0.09 2 0.08 50
*
open homedir/tools/space-time/dispers/ig1.ctl
set dfile 5
set t 1
set vpage 0 11 0 8.5
set grads off
set parea 0.8 3.6 4.55 7.3
set parea 1 5 1.5 6.5
set xlopts 1 7 0.0
set ylopts 1 7 0.0
set lon -15 15
set y 1
*set axlim 0.01 0.5
set axlim 0.008 0.5
set cmark 0
set ccolor 2
set z 1
d ig1
set cmark 0
set ccolor 2
set z 2
d ig1
set cmark 0
set ccolor 2
set z 3
d ig1
run homedir/tools/space-time/draw_string2.gs 5.5 0.45 1 0.12 n=1 EIG
run homedir/tools/space-time/draw_string2.gs -8.5 0.45 1 0.12 n=1 WIG
run homedir/tools/space-time/draw_string.gs 0.5 0.38 2 0.08 12
run homedir/tools/space-time/draw_string.gs 0.5 0.45 2 0.08 25
*
run homedir/tools/space-time/draw_string2.gs 7.5 0.06 1 0.12 MJO
close 5
close 4
close 3

open homedir/tools/space-time/dispers/mrg.ctl
set dfile 3
set t 1
set vpage 0 11 0 8.5
set parea 6.0 10.0 1.5 6.5
set grads off
set xlopts 1 7 0.11
set ylopts 1 7 0.11
set x 1
set y 1 101
set axlim -15 15
set cmark 0
set ccolor 2
set xyrev on
set z 1
d mrg
set cmark 0
set ccolor 2
set z 2
d mrg
set cmark 0
set ccolor 2
set z 3
d mrg
run homedir/tools/space-time/draw_string2.gs 8.5 0.40 1 0.12 n=0 EIG
run homedir/tools/space-time/draw_string2.gs -8.5 0.15 1 0.12 MRG
run homedir/tools/space-time/draw_string.gs 5.5 0.45 2 0.08 50
run homedir/tools/space-time/draw_string.gs 9.3 0.45 2 0.08 25
run homedir/tools/space-time/draw_string.gs 14.0 0.42 2 0.08 12
*
run homedir/tools/space-time/draw_string2.gs 7.5 0.05 1 0.12 MJO
*
open homedir/tools/space-time/dispers/ig2.ctl
set dfile 4
set t 1
set vpage 0 11 0 8.5
set parea 6.0 10.0 1.5 6.5
set grads off
set xlopts 1 7 0.0
set ylopts 1 7 0.0
set lon -15 15
set y 1
*set axlim 0.01 0.5
set axlim 0.008 0.5
set cmark 0
set ccolor 2
set z 1
d ig2
set cmark 0
set ccolor 2
set z 2
d ig2
set cmark 0
set ccolor 2
set z 3
d ig2
*

set vpage off
set grads off
set vpage 0 11 0 8.5
set grads off
set line 0
draw recf 0.9 7.1 1.8 7.25 
draw recf 2.6 7.1 3.5 7.25 
set string 1 l 1
set strsiz 0.12
draw string 1.0 6.7 WESTWARD
draw string 6.0 6.7 WESTWARD
set string 1 r 1
draw string 5.0 6.7 EASTWARD
draw string 10.0 6.7 EASTWARD

set strsiz 0.15
set string 1 c 1
draw string 3.0 7.0 Symmetric
draw string 8.0 7.0 Antisymmetric
set strsiz 0.12
*draw string 9.5 6.2 (mm s`a-1`n)`a2`n
set strsiz 0.13
set string 1 c 2 90
draw string 0.2 4 FREQUENCY (cpd)
set string 1 c 2 90
draw string 10.5 4.0 PERIOD (day)
set string 1 c 2 0
draw string 3.0 1.1 ZONAL WAVENUMBER
draw string 8.0 1.1 ZONAL WAVENUMBER
*
close 4
close 3
close 2
close 1

set string 1 c
set strsiz 0.20
draw string 5.5 8.0 MJO Multi-scale metrics : Coherence`a2`n and Phase
set string 1 c
set strsiz 0.12
draw string 5.5 7.6 Variable (Data) : OLR (title_var) and title_mjo (title_var), Period : period
draw string 5.5 7.3 256-day segment, 206-day overlapping
*
set string 1 r
set strsiz 0.12
*draw string 10.8 0.3 *Reference: Hendon and Wheeler

*printim coh2.vname.gif gif x770 y595 white
printim coh2.vname.png x770 y595 white
*print 
*disable print
