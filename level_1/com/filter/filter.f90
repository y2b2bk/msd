program filter 

implicit none
!****Name List Variables ***
character(100) :: input_type,input_name,output_type!,output_name
character(200) :: output_name
character(100) :: flt_coef,i_format,o_format
real           :: missing_value
integer        :: nx,ny,nt
namelist /input/ input_type,input_name, i_format,nx,ny, nt,flt_coef,missing_value
namelist /output/ output_type,output_name ,o_format

!*** Allocatables
real , dimension(:)  , allocatable :: beta
real , dimension(:,:), allocatable :: tser,fser

!***Local Variable
integer        :: lag,i,j,k,itmp,k1,k2, is, ix, iy, it
real :: rtmp,sum

!*** Main starts herhe
read(*,nml=input)
read(*,nml=output)

print *,'output_type=',trim(output_type)
print *,'input_name=',trim(input_name)
print *,'output_name=',trim(output_name)

itmp=0 !Later lag is determined automatically


!*** Read Filter Coefficients
open(10,file=flt_coef,form='formatted',status='old')
!Determine lag 
do while (.TRUE.)
   read(10,'(F13.5)',end=100) rtmp 
   itmp=itmp+1
end do
100 lag=itmp-1
rewind(10)
allocate( beta(0:lag))
read(10,'(f13.5)') ( beta(k),k=0,lag)
close(10)

!***Read Input Data
allocate(tser(nx,nt),fser(nx,nt))

print *,'lag=',lag
print *,'nx=',nx
print *,'ny=',ny
print *,'nt=',nt

do iy=1,ny

if( input_type .eq. 'gdat' ) then
   open(10,file=input_name,form='unformatted',status='unknown', &
        !access='direct',recl=nx)
        access='direct',recl=4*nx)
   do it = 1, nt
    read(10,rec=ny*(it-1)+iy) (tser(ix,it),ix=1,nx)
   enddo
   close(10)
endif

!Filtering
 

   do ix = 1, nx

   !if ( any( tser(ix,:) .eq. missing_value ) .eq. .true. ) then
   if ( any( tser(ix,:) .eq. missing_value ) ) then
      print *, 'missing occurred'
      print *, 'missing specified', missing_value
      
      !missing
      fser(ix,:)=missing_value
      goto 10
   endif

   do it=1,nt
      sum=beta(0)*tser(ix,it)
      do k=1,lag
         k1=mod(nt+it-k-1,nt)+1
         k2=mod(it+k-1,nt)+1
         sum=sum+beta(k)*(tser(ix,k1)+tser(ix,k2))
      enddo
      fser(ix,it)=sum  
   enddo ! it

10 continue

   enddo ! ix
  

!***Write Output Data
! print *,'output_name=',trim(output_name)
if( output_type .eq. 'gdat' ) then
!   open(10,file=output_name,form='unformatted',status='unknown', &
   open(10,file=trim(output_name),form='unformatted',status='unknown', &
        !access='direct',recl=nx)
        access='direct',recl=4*nx)
   do it = 1, nt
   write(10,rec=ny*(it-1)+iy) (fser(ix,it),ix=1,nx)
   enddo
   close(10)
endif

enddo ! iy

stop
end

