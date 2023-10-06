program laged_linear_regression_2d

! laged linear regression

 implicit none

 integer :: imax, jmax, kmax, ksel, vmax, rmax, smax, dmax, tmax, filt_wing
 integer :: ymax, year1, season, leap, linux, fac1, fac2
 integer :: isel, jsel, ip, jp
 real :: ilon, dlon, jlat, dlat
 integer :: lag_time
 character(len=200) :: inname1, inname2, outname
 real :: dmiss

 real,dimension(:,:),allocatable :: var1
 real,dimension(:),allocatable :: var2
 real,dimension(:,:,:,:),allocatable :: sel_var1
 real,dimension(:),allocatable :: sel_var2
 real,dimension(:,:),allocatable :: sum_var1, n_var1
 real,dimension(:),allocatable :: sum_var2, n_var2
 real,dimension(:,:),allocatable :: var2_1
 real,dimension(:),allocatable :: var2_2
 real,dimension(:,:),allocatable :: ab, n_ab, bb, n_bb, reg, cor
 real,dimension(:),allocatable :: aa, n_aa

 integer :: i, j, iz, it, inv, ilag, iy, id, nd, yy, dd, skip, nod
 integer :: icenter, i_shift, i_2d, i_out

! namelist
! ksel : select number of levels from bottom
! vmax : total variable
! rmax : number of total record in input file
! smax : number of total record in output file (=ksel*vmax)

 namelist /dimension_nml/ imax, jmax, kmax, ksel, vmax, rmax, smax, dmax, tmax, &
        filt_wing, ymax, season, year1, leap, linux
 namelist /region_nml/ isel, jsel, ip, jp, ilon, dlon, jlat, dlat
 namelist /lag_nml/ lag_time
 namelist /filename_nml/ inname1, inname2, outname
 namelist /dmiss_nml/ dmiss

 open (99, file='input.nml')
 read (99, nml=dimension_nml)
 read (99, nml=region_nml)
 read (99, nml=lag_nml)
 read (99, nml=filename_nml)
 read (99, nml=dmiss_nml)


 allocate (var1(imax,jmax),var2(1))
 allocate (sel_var1(isel,jsel,tmax,smax))
 allocate (sel_var2(tmax))
 allocate (sum_var1(isel,jsel))
 allocate (sum_var2(1))
 allocate (n_var1(isel,jsel))
 allocate (n_var2(1))
 allocate (var2_1(isel,jsel))
 allocate (var2_2(1))
 allocate (ab(isel,jsel))
 allocate (n_ab(isel,jsel))
 allocate (bb(isel,jsel))
 allocate (n_bb(isel,jsel))
 allocate (aa(1))
 allocate (n_aa(1))
 allocate (reg(isel,jsel))
 allocate (cor(isel,jsel))


 open (1,file= &
 trim(inname1),&
form='unformatted', access='direct', recl=imax*jmax*linux, status='old')
 open (11,file= &
 trim(inname2),&
form='unformatted', access='direct', recl=1*linux, status='old')
 open (2,file= &
 trim(outname)//'.llreg_2d.gdat', &
 form='unformatted', access='direct', recl=isel*jsel*linux, status='unknown')
 open (99, file=&
 trim(outname)//'.llreg_2d.ctl', status='unknown')

! read just once!!!
var1 = 0.
var2 = 0.
sel_var1 = 0.
sel_var2 = 0.

do inv = 1, vmax
do iz = 1, ksel

 do it = 1, tmax
   read(1, rec = rmax*(it-1)+kmax*(inv-1)+iz ) var1
  do j = 1, jsel
  do i = 1, isel
    sel_var1(i,j,it,ksel*(inv-1)+iz) = var1(i+ip-1,j+jp-1)
  enddo
  enddo
 enddo

enddo !inv
enddo !iz

 do it = 1, tmax
   read(11, rec = it ) var2(1)
   sel_var2(it) = var2(1)
 enddo

 do inv = 1, vmax
 print*,'variable:',inv
 do iz = 1, ksel
 print*,'z:',iz

 do ilag = -lag_time, lag_time
 print*,'LAG DAY :',ilag

sum_var1 = 0.
sum_var2 = 0.
n_var1 = 0.
n_var2 = 0.

 yy = year1 - 1
 dd = 0

  do iy = 1, ymax

    yy = yy + 1

  if (leap.eq.1) then

    nod = 365
    if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nod = 366
    if (mod(yy,400).eq.0) nod = 366


    if (season.eq.1) then

      skip = 304
      if (nod.eq.366) skip = 305

     nd = 181
     if (mod(yy+1,4).eq.0.and.mod(yy+1,100).ne.0) nd = 182
     if (mod(yy,400).eq.0) nd = 182

    elseif (season.eq.2) then

     skip = 120
     if (nod.eq.366) skip = 121
     nd = 184

    endif

   elseif (leap.eq.0) then

   if (dmax.eq.360) then
    if (season.eq.1) then
     skip = 300
     nd = 180
    elseif (season.eq.2) then
     skip = 120
     nd = 180
    endif
   else ! dmax = 365
    if (season.eq.1) then
     skip = 304
     nd = 181
    elseif (season.eq.2) then
     skip = 120
     nd = 184
    endif
   !else
   endif

   endif

  do id = 1, nd

  if (leap.eq.1) then

      it = dd + skip + id

  elseif (leap.eq.0) then

      it = dmax*(iy-1)+skip+id

  endif

 if (it+ilag.gt.0+filt_wing.and.it+ilag.lt.tmax+1-filt_wing) then  ! if-ilag

  do j = 1, jsel
  do i = 1, isel
   if (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz).ne.dmiss) then
    sum_var1(i,j) = sum_var1(i,j) + sel_var1(i,j,it+ilag,ksel*(inv-1)+iz)
    n_var1(i,j) = n_var1(i,j) + 1
   endif
  enddo
  enddo

   if (sel_var2(it).ne.dmiss) then
    sum_var2(1) = sum_var2(1) + sel_var2(it)
    n_var2(1) = n_var2(1) + 1
   endif

endif ! endif-ilag


  enddo ! id

! for leap year 
    if (leap.eq.1) then
     dd = dd + nod
    endif

  enddo ! iy

  do j = 1, jsel
  do i = 1, isel
   if (n_var1(i,j).ne.0) then
    sum_var1(i,j) = sum_var1(i,j)/n_var1(i,j)
   else
    sum_var1(i,j) = dmiss
   endif
  enddo
  enddo

   if (n_var2(1).ne.0) then
    sum_var2(1) = sum_var2(1)/n_var2(1)
   else
    sum_var2(1) = dmiss
   endif


ab = 0.
bb = 0.
aa = 0.
n_ab = 0.
n_aa = 0.
n_bb = 0.

 yy = year1 - 1
 dd = 0

  do iy = 1, ymax

    yy = yy + 1

  if (leap.eq.1) then

    nod = 365
    if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nod = 366
    if (mod(yy,400).eq.0) nod = 366

    if (season.eq.1) then

     skip = 304
     if (nod.eq.366) skip = 305

     nd = 181
     if (mod(yy+1,4).eq.0.and.mod(yy+1,100).ne.0) nd = 182
     if (mod(yy,400).eq.0) nd = 182

    elseif (season.eq.2) then

     skip = 120
     if (nod.eq.366) skip = 121

     nd = 184

    endif

   elseif (leap.eq.0) then

   if (dmax.eq.360) then
    if (season.eq.1) then
     skip = 300
     nd = 180
    elseif (season.eq.2) then
     skip = 120
     nd = 180
    endif
   else ! dmax = 365
    if (season.eq.1) then
     skip = 304
     nd = 181
    elseif (season.eq.2) then
     skip = 120
     nd = 184
    endif
   endif

   endif

  do id = 1, nd

  if (leap.eq.1) then

      it = dd + skip + id

   elseif (leap.eq.0) then

      it = dmax*(iy-1)+ skip + id

  endif

 if (it+ilag.gt.0+filt_wing.and.it+ilag.lt.tmax+1-filt_wing) then

  do j = 1, jsel
  do i = 1, isel
   if (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz).ne.dmiss.and.sum_var1(i,j) &
       .ne.dmiss.and.sel_var2(it).ne.dmiss.and.sum_var2(1).ne.dmiss) then
    ab(i,j) = ab(i,j) + (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz)-sum_var1(i,j))*(sel_var2(it)-sum_var2(1))
    n_ab(i,j) = n_ab(i,j) + 1
   endif
  enddo
  enddo

  do j = 1, jsel
  do i = 1, isel
   if (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz).ne.dmiss.and.sum_var1(i,j).ne.dmiss) then
    bb(i,j) = bb(i,j) + (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz)-sum_var1(i,j)) &
    *(sel_var1(i,j,it+ilag,ksel*(inv-1)+iz)-sum_var1(i,j))
    n_bb(i,j) = n_bb(i,j) + 1
   endif
  enddo
  enddo

   if (sel_var2(it).ne.dmiss.and.sum_var2(1).ne.dmiss) then
    aa(1) = aa(1) + (sel_var2(it)-sum_var2(1))*(sel_var2(it)-sum_var2(1))
    n_aa(1) = n_aa(1) + 1
   endif

 endif ! endif-ilag
  enddo ! id

! for leap year winter season
    if (leap.eq.1) then
     dd = dd + nod
    endif

  enddo ! iy

  do j = 1, jsel
  do i = 1, isel
   if (n_ab(i,j).ne.0.and.n_aa(1).ne.0.and.aa(1).ne.0) then
    reg(i,j) = (ab(i,j)/n_ab(i,j))/(aa(1)/n_aa(1))
   else
    reg(i,j) = dmiss
   endif
   if (n_ab(i,j).ne.0.and.n_aa(1).ne.0.and.aa(1).ne.0.and.n_bb(i,j).ne.0.and.bb(i,j).ne.0) then
    cor(i,j) = (ab(i,j)/n_ab(i,j))/(sqrt(aa(1)/n_aa(1))*sqrt(bb(i,j)/n_bb(i,j)))
   else
    cor(i,j) = dmiss
   endif
  enddo
  enddo

 write(2, rec=3*(ilag+lag_time)+1) reg
 write(2, rec=3*(ilag+lag_time)+2) cor
 write(2, rec=3*(ilag+lag_time)+3) n_bb

 enddo ! ilag  

 enddo ! iz
 enddo ! inv

!make ctl
! ev
   write (99, 1110)  'DSET '//trim(outname)//'.llreg_2d.gdat                                                                     '
   write (99, 1119) dmiss
   write (99, 1112) isel, ilon+dlon*(ip-1), dlon
   write (99, 1113) jsel, jlat+dlat*(jp-1), dlat
   write (99, 1111)  'ZDEF 1 LEVELS 1000                               '
   write (99, 1115) lag_time*2+1
   write (99, 1116) 3
   write (99, 1117) 'reg'
   write (99, 1117) 'cor'
   write (99, 1117) 'dof'
   write (99, 1111)  'ENDVARS                                                       '

1110   format (a80)
1111   format (a30)
1119   format ('UNDEF ',e15.7)
1112   format ('XDEF 'i4,1x'LINEAR 'f10.5, 1x, f8.5)
1113   format ('YDEF 'i4,1x'LINEAR 'f10.5, 1x, f8.5)
1115   format ('TDEF 'i5,1x'LINEAR 01jan1979 1yr')
1116   format ('VARS ',i3)
1117   format (a3,1x,'0 0 var')


end program laged_linear_regression_2d
