 program comp

 implicit none

  integer, parameter :: imax = num_x, jmax = num_y, tmax = num_t 
  integer, parameter :: dmax = num_d

! year1 : 1st year, year2 : last year
 integer, parameter :: year1 = beg_y, year2 = end_y

! leap = 1 : leap year
! leap = 0 : no leap year
 integer, parameter :: leap = leap_year

! linux = 4 : linux machine (recl*4)
! linux = 1 : other machine (recl)
 integer, parameter :: linux = linux_recl

  real,dimension(imax,jmax) :: var
  real,dimension(imax,jmax,8) :: com_sum, n_com_sum
  real,dimension(imax,jmax,8) :: com_win, n_com_win
  real,dimension(tmax) :: amp, pha
  real :: miss

  real :: num_sum(8), num_win(8)
  integer :: julian(tmax)
  integer :: phase, dd
  integer :: beg_sum, end_sum
  integer :: i, j, it, yy, nd, id

  data miss /dmiss/
 
  open (11, file='homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.gdat',&
 form='unformatted', access='direct', recl=imax*jmax*linux_recl, status='old')

  open (12, file='homedir/level_2/comp/data/amp_pha', &
 form='unformatted', access='direct', recl=1*linux_recl, status='old')

! summer output
  open (13, file='homedir/level_2/comp/variable/comp.sum.gdat', &
 form='unformatted', access='direct', recl=imax*jmax*linux_recl, status='unknown')
  open (14, file='homedir/level_2/comp/variable/n_comp.sum.gdat', &
 form='unformatted', access='direct', recl=1*linux_recl, status='unknown')

! winter output
  open (15, file='homedir/level_2/comp/variable/comp.win.gdat', &
 form='unformatted', access='direct', recl=imax*jmax*linux_recl, status='unknown')
  open (16, file='homedir/level_2/comp/variable/n_comp.win.gdat', &
 form='unformatted', access='direct', recl=1*linux_recl, status='unknown')

 do it = 1, tmax
  read (12,rec=2*(it-1)+1) amp(it)
  read (12,rec=2*(it-1)+2) pha(it)
 enddo

 if (leap.eq.1) then

 it = 0

 do yy = year1, year2
 nd = dmax
 if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nd = dmax + 1
 if (mod(yy,400).eq.0) nd = dmax + 1

 do id = 1, nd

 it = it + 1

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

 else

  do it = 1, tmax
   julian(it) = mod(it,dmax)
   if (julian(it).eq.0) julian(it) = dmax
  enddo ! it

 endif


 num_sum = 0
 num_win = 0
 com_sum = 0.
 com_win = 0.
 n_com_sum = 0.
 n_com_win = 0.


 do it = 1, tmax

 dd = julian(it)

  read (11,rec=it) var

  if (amp(it).gt.1) then

 if (dmax.eq.360) then
 beg_sum = 120
 end_sum = 300
 else 
 beg_sum = 120
 end_sum = 305
 endif

 if (leap.eq.1) then
 beg_sum = 121
 end_sum = 306
 endif


  if (mod(dd,365).gt.beg_sum.and.mod(dd,365).lt.end_sum) then

   phase = pha(it)
   
   num_sum(phase) = num_sum(phase) + 1

    do j = 1, jmax
    do i = 1, imax
      if (var(i,j).ne.miss) then
       com_sum(i,j,phase) = com_sum(i,j,phase) + var(i,j)
       n_com_sum(i,j,phase) = n_com_sum(i,j,phase) + 1
      endif
    enddo
    enddo

  else

   phase = pha(it)
   
   num_win(phase) = num_win(phase) + 1

    do j = 1, jmax
    do i = 1, imax
      if (var(i,j).ne.miss) then
       com_win(i,j,phase) = com_win(i,j,phase) + var(i,j)
       n_com_win(i,j,phase) = n_com_win(i,j,phase) + 1
      endif
    enddo
    enddo

  endif ! season

  endif ! amp

 enddo ! it

 do it = 1, 8
 print*,'summer phase ',it,'number ',num_sum(it)
    do j = 1, jmax
    do i = 1, imax
      if (n_com_sum(i,j,it).ne.0) then
       com_sum(i,j,it) = com_sum(i,j,it)/n_com_sum(i,j,it)
      else
       com_sum(i,j,it) = miss
      endif
    enddo
    enddo

   write(13,rec=it) com_sum(:,:,it)
   write(14,rec=it) num_sum(it)
 enddo

 do it = 1, 8
 print*,'winter phase ',it,'number ',num_win(it)
    do j = 1, jmax
    do i = 1, imax
      if (n_com_win(i,j,it).ne.0) then
       com_win(i,j,it) = com_win(i,j,it)/n_com_win(i,j,it)
      else
       com_win(i,j,it) = miss
      endif
    enddo
    enddo

   write(15,rec=it) com_win(:,:,it)
   write(16,rec=it) num_win(it)
 enddo

 end program comp
