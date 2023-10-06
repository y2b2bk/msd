program laged_linear_regression_2d

! laged linear regression

 implicit none

 integer :: imax, jmax, kmax, ksel, vmax, rmax, smax, tmax, filt_wing
 integer :: linux, fac1, fac2
 integer :: isel, jsel, ip, jp
 real :: ilon, dlon, jlat, dlat
 integer :: lag_time
 character(len=200) :: inname1, inname2, outname
 real :: dmiss
 intrinsic :: mod

 real,dimension(:,:),allocatable :: var1
 real,dimension(:),allocatable :: var2
 real,dimension(:,:,:,:),allocatable :: sel_var1
 real,dimension(:),allocatable :: sel_var2
 real,dimension(:,:),allocatable :: sum_var1, n_var1
 real,dimension(:),allocatable :: sum_var2, n_var2
 real,dimension(:,:),allocatable :: var2_1
 real,dimension(:),allocatable :: var2_2
 real,dimension(:,:),allocatable :: ab, n_ab, bb, n_bb, reg, cor
 real,dimension(:,:,:),allocatable :: ave_reg, n_ave_reg, ave_cor, n_ave_cor
 real,dimension(:),allocatable :: aa, n_aa

 integer :: i, j, iz, it, inv, ilag, iy, dd, yy
 integer :: icenter, i_shift, i_2d, i_out

! namelist
! ksel : select number of levels from bottom
! vmax : total variable
! rmax : number of total record in input file
! smax : number of total record in output file (=ksel*vmax)

 namelist /dimension_nml/ imax, jmax, kmax, ksel, vmax, rmax, smax, tmax, filt_wing, linux, fac1, fac2
 namelist /region_nml/ isel, jsel, ip, jp, ilon, dlon, jlat, dlat
 namelist /lag_nml/ lag_time
 namelist /filename_nml/ inname1, outname
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
 allocate (ave_reg(isel,jsel,2*lag_time+1))
 allocate (n_ave_reg(isel,jsel,2*lag_time+1))
 allocate (cor(isel,jsel))
 allocate (ave_cor(isel,jsel,2*lag_time+1))
 allocate (n_ave_cor(isel,jsel,2*lag_time+1))


 open (1,file= &
 trim(inname1),&
form='unformatted', access='direct', recl=imax*jmax*linux, status='old')
 open (2,file= &
 trim(outname)//'.llreg_2d.gdat', &
 form='unformatted', access='direct', recl=isel*jsel*linux, status='unknown')
 open (99, file=&
 trim(outname)//'.llreg_2d.ctl', status='unknown')

! initialization
ave_cor = 0.
n_ave_cor = 0.
ave_reg = 0.
n_ave_reg = 0.

! read just once!!!
var1 = 0.
var2 = 0.
sel_var1 = 0.
sel_var2 = 0.

do inv = 1, vmax
do iz = 1, ksel

 do it = 1, tmax
   read(1, rec = 10*(it-1)+1 ) var1
  do j = 1, jsel
  do i = 1, isel
    sel_var1(i,j,it,ksel*(inv-1)+iz) = fac1*var1(i+ip-1,j+jp-1)
  enddo
  enddo
 enddo

enddo !inv
enddo !iz

 do it = 1, tmax
   read(1, rec = 10*(it-1)+2 ) var2(1)
    sel_var2(it) = fac2*var2(1)
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

 do it = 1, tmax

 if (it+ilag.gt.0.and.it+ilag.lt.tmax+1) then  ! if-ilag

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

 enddo ! it

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

  do it = 1, tmax

 if (it+ilag.gt.0.and.it+ilag.lt.tmax+1) then

  do j = 1, jsel
  do i = 1, isel
   if (sel_var1(i,j,it+ilag,ksel*(inv-1)+iz).ne.dmiss.and.sum_var1(i,j).ne.&
    dmiss.and.sel_var2(it).ne.dmiss.and.sum_var2(1).ne.dmiss) then
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

 enddo ! it

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

  do j = 1, jsel
  do i = 1, isel
   if (cor(i,j).ne.dmiss) then
    ave_cor(i,j,ilag+lag_time+1) = ave_cor(i,j,ilag+lag_time+1)+cor(i,j)
    n_ave_cor(i,j,ilag+lag_time+1) = n_ave_cor(i,j,ilag+lag_time+1) + 1
   endif
   if (reg(i,j).ne.dmiss) then
    ave_reg(i,j,ilag+lag_time+1) = ave_reg(i,j,ilag+lag_time+1)+reg(i,j)
    n_ave_reg(i,j,ilag+lag_time+1) = n_ave_reg(i,j,ilag+lag_time+1) + 1
   endif
  enddo
  enddo

 enddo ! ilag  


 do ilag = -lag_time, lag_time

 do j = 1, jsel
 do i = 1, isel
   if (n_ave_cor(i,j,ilag+lag_time+1).ne.0) then
    ave_cor(i,j,ilag+lag_time+1) = ave_cor(i,j,ilag+lag_time+1)/n_ave_cor(i,j,ilag+lag_time+1)
   endif
   if (n_ave_reg(i,j,ilag+lag_time+1).ne.0) then
    ave_reg(i,j,ilag+lag_time+1) = ave_reg(i,j,ilag+lag_time+1)/n_ave_reg(i,j,ilag+lag_time+1)
   endif
 enddo
 enddo

 write(2, rec=2*(ilag+lag_time)+1) ave_reg(:,:,ilag+lag_time+1)
 write(2, rec=2*(ilag+lag_time)+2) ave_cor(:,:,ilag+lag_time+1)

 enddo ! ilag


 enddo ! iz
 enddo ! inv

!make ctl
! ev
   write (99, 1110)  'DSET '//trim(outname)//'.llreg_2d.gdat                                                   '
   write (99, 1119) dmiss
   write (99, 1112) isel, ilon+dlon*(ip-1), dlon
   write (99, 1113) jsel, jlat+dlat*(jp-1), dlat
   write (99, 1111)  'ZDEF 1 LEVELS 1000                               '
   write (99, 1115) lag_time*2+1
   write (99, 1116) 2
   write (99, 1117) 'reg'
   write (99, 1117) 'cor'
   write (99, 1111)  'ENDVARS                                                       '

1110   format (a80)
1111   format (a30)
1119   format ('UNDEF ',e15.7)
1112   format ('XDEF 'i4,1x'LINEAR 'f10.5, 1x, f8.5)
1113   format ('YDEF 'i4,1x'LINEAR 'f10.5, 1x, f8.5)
1115   format ('TDEF 'i5,1x'LINEAR 01jan1950 1yr')
1116   format ('VARS ',i3)
1117   format (a3,1x,'0 0 var')


end program laged_linear_regression_2d
