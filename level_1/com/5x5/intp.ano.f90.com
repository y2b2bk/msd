program intp_sst_sic

implicit none

 integer, parameter :: nxfrom= num_x, nyfrom= num_y, nxto= sel_x, nyto= sel_y 
 integer, parameter :: linux = linux_recl
 real, dimension(nxfrom) :: xfrom
 real, dimension(nyfrom) :: yfrom
 real, dimension(nxto) :: xto
 real, dimension(nyto) :: yto
 real, dimension(nxto,nyto) :: ts, gdat, temp, gsum
 real, dimension(nxfrom,nyfrom) :: dummy
 real :: dxfrom, dyfrom, dxto, dyto
 integer, dimension(nxto, nyto) :: nsum
 character(len=4) :: ayr
 integer :: i, j, iyr, imo,  nundef, iz
      
 real :: undef
 data undef /missing/

 logical :: extrap
 data extrap /.true./

 character(len=8) :: xintp,yintp
 data xintp,yintp /'linear','linear'/


 open( 1,file='homedir/&
      level_1/variable/data/daily.5x5.anom.period.gdat', &
      form='unformatted',&
      access='direct', recl=nxto*nyto*linux,status='unknown')

 dxfrom = 360./float(nxfrom)
 dyfrom = dxfrom
 dxto   = 360./float(nxto)  
 dyto   = dxto

 do i=1,nxfrom ; xfrom(i) = 0.+(i-1)*dxfrom      ; enddo
 do j=1,nyfrom ; yfrom(j) = beg_lat+(j-1)*dyfrom ; enddo
 do i=1,nxto   ; xto(i) = 0.+(i-1)*dxto            ; enddo
 do j=1,nyto   ; yto(j) = sel_lat+(j-1)*dyto ; enddo

 open(10,file='homedir/&
      level_1/variable/data/daily.anom.period.gdat', &
      form='unformatted',&
      access='direct',recl=nxfrom*nyfrom*linux,status='old')

 do imo = 1, num_t

  read(10,rec=imo)((dummy(i,j),i=1,nxfrom),j=1,nyfrom)  
  call treatmiss ( dummy, undef, nxfrom, nyfrom )
  call bilini(dummy,xfrom,yfrom,nxfrom,nyfrom,ts,xto,yto,&
          nxto,nyto,xintp,yintp,extrap,undef,nundef)
  write(1,rec=imo)((ts(i,j),i=1,nxto),j=1,nyto)

 enddo ! imo

  end program
!------------------------------------------------------------
  subroutine treatmiss ( dummy, undef, nxfrom, nyfrom )
  implicit none

  integer :: nxfrom, nyfrom
  real, dimension(nxfrom,nyfrom) :: dummy
  real :: asum, bsum, undef
  integer :: i, j, msum

  bsum=0.

  do j=1,nyfrom
   msum=0
   asum=0.

  do i=1,nxfrom
   if(dummy(i,j).ne.undef) then
    asum=asum+dummy(i,j)
    msum=msum+1
   endif
  enddo

   if (msum.gt.0) then
    bsum=asum/msum
   endif
   do i=1,nxfrom
    if(dummy(i,j).eq.undef) dummy(i,j)=bsum
   enddo

  enddo

  end subroutine
