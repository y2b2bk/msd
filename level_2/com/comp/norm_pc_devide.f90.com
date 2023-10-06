 program norm_pc

 implicit none

 integer, parameter :: tmax = num_t
 integer, parameter :: linux = linux_recl
 real, dimension(2,tmax) :: pc, n_pc
 real :: ave, n_ave, var, std
 real :: amp, pha, pi, pc1, pc2, tmp
 integer :: iv, it

 open (1, file='homedir/level_2/ceof/ceof.ts', &
 form='unformatted', access='direct', recl=1*linux, status='old')
 open (2, file='homedir/level_2/comp/data/amp_pha', &
 form='unformatted', access='direct', recl=1*linux, status='unknown')

  pi = 4.*atan(1.)

 do iv = 1, 2
  ave = 0.
  n_ave = 0.
  var = 0.
  std = 0.
 do it = 1, tmax
  read (1, rec=10*(it-1)+iv) pc(iv,it)
 
  if (pc(iv,it).ne.-999.) then
   ave = ave + pc(iv,it)
   n_ave = n_ave + 1
  endif
 
 enddo ! it

   ave = ave/n_ave

 print*,'pc ',iv,'ave ',ave
   
 do it = 1, tmax
  if (pc(iv,it).ne.-999.) then
   var = var + (pc(iv,it)-ave)**2
  endif
 enddo ! it

  var = var/(n_ave-1)

  std = sqrt(var)

 do it = 1, tmax
  n_pc(iv,it) = (pc(iv,it)-ave)/std
  write(2, rec=2*(it-1)+iv) n_pc(iv,it)
 enddo ! it

 enddo ! iv

  do it = 1, tmax

   pc1 = sign1*pc(1,it)
   pc2 = sign2*pc(2,it)
  
   amp = sqrt(pc1**2+pc2**2)
 
  if (pc1.ne.0) then
   tmp = atan(pc2/pc1)

    if (pc2*pc1.gt.0) then
     if (pc1.lt.0) tmp = tmp + pi
    else
     if (pc2.gt.0) tmp = pi + tmp
     if (pc2.lt.0) tmp = 2*pi + tmp
    endif
  else
   tmp = 10000
  endif

  if (tmp.ne.10000) then

   if (tmp.gt.pi.and.tmp.lt.pi+pi/4.) then
    pha = 1
   elseif (tmp.gt.pi+pi/4..and.tmp.lt.pi+2*pi/4.) then
    pha = 2
   elseif (tmp.gt.pi+2*pi/4..and.tmp.lt.pi+3*pi/4.) then
    pha = 3
   elseif (tmp.gt.pi+3*pi/4..and.tmp.lt.2*pi) then
    pha = 4
   elseif (tmp.gt.0..and.tmp.lt.pi/4.) then
    pha = 5
   elseif (tmp.gt.pi/4..and.tmp.lt.2*pi/4.) then
    pha = 6
   elseif (tmp.gt.2*pi/4..and.tmp.lt.3*pi/4.) then
    pha = 7
   elseif (tmp.gt.3*pi/4..and.tmp.lt.pi) then
    pha = 8
   else
    pha = -1
   endif

  else
   pha = -1
  endif

  write(2, rec=2*(it-1)+1) amp
  write(2, rec=2*(it-1)+2) pha

  enddo ! it

 end program norm_pc
