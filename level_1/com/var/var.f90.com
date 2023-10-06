 program variance

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

  real, dimension(imax,jmax,tmax) :: raw, fil 
  real, dimension(imax,jmax) :: var_raw_all, n_var_raw_all
  real, dimension(imax,jmax) :: var_raw_sum, n_var_raw_sum
  real, dimension(imax,jmax) :: var_raw_win, n_var_raw_win
  real, dimension(imax,jmax) :: var_fil_all, n_var_fil_all
  real, dimension(imax,jmax) :: var_fil_sum, n_var_fil_sum
  real, dimension(imax,jmax) :: var_fil_win, n_var_fil_win
  real :: dmiss
  integer, dimension(tmax) :: julian
  integer :: i, j, iy, id, it, dd, ddmax, nd, yy
  integer :: beg_sum, end_sum
  data dmiss/missing/

  open (1, file='homedir/level_1/variable/data/daily.anom.period.gdat', &
  access='direct', recl=imax*jmax*linux, status='old')
  open (2, file='homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.gdat', &
  access='direct', recl=imax*jmax*linux, status='old')

 open (11, file='homedir/level_1/variable/var/raw.all.gdat', &
  access='direct', recl=imax*jmax*linux, status='unknown')
 open (12, file='homedir/level_1/variable/var/raw.sum.gdat', &
  access='direct', recl=imax*jmax*linux, status='unknown')
 open (13, file='homedir/level_1/variable/var/raw.win.gdat', &
  access='direct', recl=imax*jmax*linux, status='unknown')

 open (21, file='homedir/level_1/variable/var/fil.all.gdat', &
  access='direct', recl=imax*jmax*linux, status='unknown')
 open (22, file='homedir/level_1/variable/var/fil.sum.gdat', &
  access='direct', recl=imax*jmax*linux, status='unknown')
 open (23, file='homedir/level_1/variable/var/fil.win.gdat', &
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
  read ( 1, rec=it) raw(:,:,it)
  read ( 2, rec=it) fil(:,:,it)

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
  read ( 1, rec=it) raw(:,:,it)
  read ( 2, rec=it) fil(:,:,it)

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
  read ( 1, rec=it) raw(:,:,it)
  read ( 2, rec=it) fil(:,:,it)

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
  julian(it) = mod(it+sday-1,365)
  if (julian(it).eq.0) julian(it) = 365
  read ( 1, rec=it) raw(:,:,it)
  read ( 2, rec=it) fil(:,:,it)
 enddo

 endif 

 do it = 1, tmax 

  dd = julian(it) 

! all

  do j = 1, jmax
  do i = 1, imax
  if (raw(i,j,it).ne.dmiss) then
   var_raw_all(i,j) = var_raw_all(i,j) + raw(i,j,it)*raw(i,j,it)
   n_var_raw_all(i,j) = n_var_raw_all(i,j) + 1
  endif
  enddo ! j
  enddo ! i
  do j = 1, jmax
  do i = 1, imax
  if (fil(i,j,it).ne.dmiss) then
   var_fil_all(i,j) = var_fil_all(i,j) + fil(i,j,it)*fil(i,j,it)
   n_var_fil_all(i,j) = n_var_fil_all(i,j) + 1
  endif
  enddo ! j
  enddo ! i

  if (leap.eq.1) then
   beg_sum = 122
   end_sum = 305
  else
   beg_sum = 121
   end_sum = 304
   if (dmax.eq.360) then
   beg_sum = 121
   end_sum = 300
   endif
  endif

! sum
  if (dd.ge.beg_sum.and.dd.le.end_sum) then

  do j = 1, jmax
  do i = 1, imax
  if (raw(i,j,it).ne.dmiss) then
   var_raw_sum(i,j) = var_raw_sum(i,j) + raw(i,j,it)*raw(i,j,it)
   n_var_raw_sum(i,j) = n_var_raw_sum(i,j) + 1
  endif
  enddo ! j
  enddo ! i
  do j = 1, jmax
  do i = 1, imax
  if (fil(i,j,it).ne.dmiss) then
   var_fil_sum(i,j) = var_fil_sum(i,j) + fil(i,j,it)*fil(i,j,it)
   n_var_fil_sum(i,j) = n_var_fil_sum(i,j) + 1
  endif
  enddo ! j
  enddo ! i

! win
  else

  do j = 1, jmax
  do i = 1, imax
  if (raw(i,j,it).ne.dmiss) then
   var_raw_win(i,j) = var_raw_win(i,j) + raw(i,j,it)*raw(i,j,it)
   n_var_raw_win(i,j) = n_var_raw_win(i,j) + 1
  endif
  enddo ! j
  enddo ! i
  do j = 1, jmax
  do i = 1, imax
  if (fil(i,j,it).ne.dmiss) then
   var_fil_win(i,j) = var_fil_win(i,j) + fil(i,j,it)*fil(i,j,it)
   n_var_fil_win(i,j) = n_var_fil_win(i,j) + 1
  endif
  enddo ! j
  enddo ! i

  endif ! season

 enddo ! it

  do j = 1, jmax
  do i = 1, imax
  if (n_var_raw_all(i,j).ne.0) then
   var_raw_all(i,j) = var_raw_all(i,j)/n_var_raw_all(i,j)
  endif
  enddo ! j
  enddo ! i
 write(11,rec=1) var_raw_all

  do j = 1, jmax
  do i = 1, imax
  if (n_var_raw_sum(i,j).ne.0) then
   var_raw_sum(i,j) = var_raw_sum(i,j)/n_var_raw_sum(i,j)
  endif
  enddo ! j
  enddo ! i
 write(12,rec=1) var_raw_sum

  do j = 1, jmax
  do i = 1, imax
  if (n_var_raw_win(i,j).ne.0) then
   var_raw_win(i,j) = var_raw_win(i,j)/n_var_raw_win(i,j)
  endif
  enddo ! j
  enddo ! i
 write(13,rec=1) var_raw_win

  do j = 1, jmax
  do i = 1, imax
  if (n_var_fil_all(i,j).ne.0) then
   var_fil_all(i,j) = var_fil_all(i,j)/n_var_fil_all(i,j)
  endif
  enddo ! j
  enddo ! i
 write(21,rec=1) var_fil_all

  do j = 1, jmax
  do i = 1, imax
  if (n_var_fil_sum(i,j).ne.0) then
   var_fil_sum(i,j) = var_fil_sum(i,j)/n_var_fil_sum(i,j)
  endif
  enddo ! j
  enddo ! i
 write(22,rec=1) var_fil_sum

  do j = 1, jmax
  do i = 1, imax
  if (n_var_fil_win(i,j).ne.0) then
   var_fil_win(i,j) = var_fil_win(i,j)/n_var_fil_win(i,j)
  endif
  enddo ! j
  enddo ! i
 write(23,rec=1) var_fil_win

 end program variance
