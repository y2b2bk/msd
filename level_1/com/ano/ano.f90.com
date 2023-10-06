program make_ano

 implicit none

 integer, parameter :: imax = num_x, jmax = num_y
 integer, parameter :: dmax = num_d, tmax = num_t

! sday : number(in julian) of the first day in the first year
! eday : number(in julian) of the last day in the last year
 integer, parameter :: sday = num_s, eday = num_e

! year1 : 1st year, year2 : last year
 integer, parameter :: year1 = beg_y, year2 = end_y

! leap = 1 : leap year
! leap = 0 : no leap year
 integer, parameter :: leap = leap_year

! linux = 4 : linux machine (recl*4)
! linux = 1 : other machine (recl)
 integer, parameter :: linux = linux_recl

 real, dimension(imax,jmax) :: ano_var
 real, dimension(imax,jmax,dmax+1) :: ave_var, n_ave_var
 real, dimension(imax,jmax,dmax+1) :: cli_var
 real, dimension(imax,jmax,tmax) :: var
 real :: dmiss
 integer, dimension(tmax) :: julian
 integer :: i, j, iy, id, it, dd, ddmax, nd, yy
 data dmiss /missing/
 
 open (1, file='homedir/level_1/variable/data/daily.period.gdat', &
 access='direct', recl=imax*jmax*linux, status='old')
 open (2, file='homedir/level_1/variable/data/daily.clim.period.gdat', &
 access='direct', recl=imax*jmax*linux, status='unknown')
 open (3, file='homedir/level_1/variable/data/daily.anom.period.gdat', &
 access='direct', recl=imax*jmax*linux, status='unknown')


 if (leap.eq.1) then

 it = 0

! first year
 yy = year1
 nd = dmax
 if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nd = dmax + 1
 if (mod(yy,400).eq.0) nd = dmax + 1

 do id = sday, nd

 it = it + 1
 read (1, rec = it ) var(:,:,it)

 if (nd.eq.dmax+1) then
 julian(it) = id 
 else
  if (id.le.59) then
   julian(it) = id 
  else
   julian(it) = id + 1
  endif
 endif
   
 enddo ! id

! years other than first and last
 do yy = year1+1, year2-1
 nd = dmax
 if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nd = dmax + 1
 if (mod(yy,400).eq.0) nd = dmax + 1

 do id = 1, nd

 it = it + 1
 read (1, rec = it ) var(:,:,it)

 if (nd.eq.dmax+1) then
 julian(it) = id 
 else
  if (id.le.59) then
   julian(it) = id 
  else
   julian(it) = id + 1
  endif
 endif
   
 enddo ! id

 enddo ! yy

! last year
 yy = year2
 nd = dmax
 if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nd = dmax + 1
 if (mod(yy,400).eq.0) nd = dmax + 1

 do id = 1, eday

 it = it + 1
 read (1, rec = it) var(:,:,it)

 if (nd.eq.dmax+1) then
 julian(it) = id 
 else
  if (id.le.59) then
   julian(it) = id 
  else
   julian(it) = id + 1
  endif
 endif
   
 enddo ! id

 else

  do it = 1, tmax
   read (1, rec = it ) var(:,:,it)
   julian(it) = mod(it+sday-1,dmax)
   if (julian(it).eq.0) julian(it) = dmax
  enddo ! it

 endif

  ave_var = 0.
  n_ave_var = 0.

 do it = 1, tmax
  dd = julian(it)

   do j = 1, jmax
   do i = 1, imax
     if (var(i,j,it).ne.dmiss) then  
       ave_var(i,j,dd) = ave_var(i,j,dd) + var(i,j,it)
       n_ave_var(i,j,dd) = n_ave_var(i,j,dd) + 1
     endif
   enddo
   enddo

 enddo ! it

 if (leap.eq.1) then
  ddmax = dmax + 1
 else
  ddmax = dmax
 endif

  do id = 1, ddmax

   do j = 1, jmax
   do i = 1, imax
     if (n_ave_var(i,j,id).ne.0) then  
       cli_var(i,j,id) = ave_var(i,j,id)/n_ave_var(i,j,id)
     else
       cli_var(i,j,id) = dmiss
     endif
   enddo
   enddo

   write (2, rec=id) cli_var(:,:,id)

 enddo ! id 

 do it = 1, tmax
  dd = julian(it)
  
  do j = 1, jmax
  do i = 1, imax
     if (var(i,j,it).ne.dmiss.and.cli_var(i,j,dd).ne.dmiss) then
      ano_var(i,j) = var(i,j,it) - cli_var(i,j,dd)
     else
      ano_var(i,j) = dmiss
     endif
  enddo 
  enddo 

   write (3, rec=it) ano_var
 enddo ! it

end program make_ano
