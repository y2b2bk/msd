      program pcspectrum
      implicit none

      integer MAXTIME,NS,NPC,nyr
      parameter (MAXTIME=10000)   ! 23+ yrs
      parameter (NS=180)          ! Number of days per segment
      parameter (NPC=1)           ! 2 PCs
      parameter (nyr = num_r)
      integer MT,num
      integer nyi(MAXTIME),nmi(MAXTIME),ndi(MAXTIME)
      real pc(MAXTIME,NPC)
      integer imd,itseg(MAXTIME), t, is, n_year, iy

      integer year1, leap, linux, dmax
      parameter (year1 = beg_year, leap = leap_year)
      parameter (dmax = num_d)
      parameter (linux = linux_recl)
      integer yy, dd, nod, it, skip, nseg

      integer NT
      parameter (NT=180)  ! enough for 6 month segments
      integer i,mx,ll
      real r1,r1AV(NPC)    ! lag-1 autocorrelations
      real ff(NT/2),vv(NT/2),vredno(NT/2)  ! plot arrays
      real vvAV(NT/2,NPC)
      real ts(NT),a(NT/2),b(NT/2),v(NT/2)
      real mean,wsave(2*NT+15)
      real totvar,totvarAV(NPC)
      real v3080,v3080red
      real sum,pos
      real vpl,vpr,vpb,vpt,ul,ur,ub,ut,cfux,cfuy
      character dd1*1,dd2*2,dd4*4,dd7*7,dd40*40
      character*100 FOUT
!      data FOUT
!     &/'homedir/level_1/mjo_var/tsps/ 
!     &in_name'/
      data FOUT &
      /'homedir/level_1/mjo_var/tsps/in_name'/

      if (NT/2..ne.float(NT/2)) then
       print*,'make NT divisible by 2 - STOP'
       STOP
      endif

! Input
      open(1,file= &
      'homedir/level_1/mjo_var/data/in_name.series', &
         access='direct', &
         form='unformatted',recl=1*linux,status='old')
!      open(1,file=
!     &'homedir/level_1/mjo_var/data/in_name.series',
!     &   access='direct',
!     &   form='unformatted',recl=1*linux,status='old')

! Output
      print *,'FOUT=',FOUT
      open(11,file=FOUT,status='unknown')

      do 88 imd = 1, NPC
       
      nseg  = 0

      call rffti(NT,wsave)   ! initialize

       do i=1,NT/2
        vvAV(i,imd)=0.
       enddo
       r1AV(imd)=0. 

      do 2003 is= sea_num, sea_num

          n_year = nyr

       yy = year1 - 1
       dd = 0

      do 2003 iy=1,n_year
       yy = yy + 1

      if (leap.eq.1) then

       nod = 365
       if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nod = 366
       if (mod(yy,400).eq.0) nod = 366

       if (is.eq.1) then

         skip = 304
         if (nod.eq.366) skip = 305

       elseif (is.eq.2) then

        skip = 120
        if (nod.eq.366) skip = 121

       endif

      elseif (leap.eq.0) then

       nod = dmax

       if (dmax.eq.360) then
        if (is.eq.1) then
         skip = 300
        elseif (is.eq.2) then
         skip = 120
        endif
       else
        if (is.eq.1) then
         skip = 304
        elseif (is.eq.2) then
         skip = 120
        endif
       endif

      endif

       nseg = nseg + 1

      do 20 t=1,NS

       if (leap.eq.1) then

           it = dd + skip + t

        elseif (leap.eq.0) then

           it = nod*(iy-1)+skip+t

        endif

         read(1,rec=it) ts(t)

  20  continue

        call fastftM(ts,NT,wsave,a,b,v,totvar,mean)

        do i=1,NT/2
         vvAV(i,imd)=vvAV(i,imd)+v(i)
        enddo

!      calculate lag-1 autocorrelation coefficient.
        call AUTO(ts,NT,NS,1,r1)
        r1AV(imd)=r1AV(imd)+r1

! for leap year
      if (leap.eq.1) then
       dd = dd + nod
      endif

2003   continue

        totvarAV(imd)=0.
        do i=1,NT/2
         vvAV(i,imd)=vvAV(i,imd)/float(nseg)
         totvarAV(imd)=totvarAV(imd)+vvAV(i,imd)
        enddo
        r1AV(imd)=r1AV(imd)/float(nseg)
        print*,'imd=',imd,'  No. of segments=', nseg,' r1AV=',r1AV(imd)

88     continue
      do 109, imd=1,NPC

!      calculate power spectrum of lag-1 autoregressive process.
       call REDNO(vredno,NT/2,r1AV(imd),totvarAV(imd))

!  ***Plot of Spectrum
       do i=1,NT/2
        ff(i)=float(i)/float(NT)
        vv(i)=vvAV(i,imd)
       enddo

       do i=1,NT/2
        vv(i)=vv(i)*ff(i)
        vredno(i)=vredno(i)*ff(i)
       enddo

        do 111 i = 1, NT/2
111     write(11,22) i, ff(i),vv(i),vredno(i)
22      format(1x,i5,3e13.5)

109   continue

      END   !main program

! --------------------------------------------------------------------------
      SUBROUTINE fastftM(ts,N,wsave,a,b,v,totvar,mean)
      implicit none

!   Uses the fftpack routines.
!   N.b. If many FFT calls will be made with the same N, then use fastftM.f
!
!   The a and b are the cosine and sine coefficients respectively.
!   v is the variance in each bin. totvar is the total variance.
!   N, the length of the series, can be either even or odd with numco=N/2

      integer N,numco,i
      real ts(N),coef(20000),a(N/2),b(N/2),v(N/2)
      real totvar,mean,wsave(2*N+15)     !>2*N+15

      numco = N/2       ! This works if N is either odd or even.
      totvar = 0.0

      do i=1,N
       coef(i)=ts(i)
      enddo

! Do the FFT.
      call rfftf(N,coef,wsave)

      do i=1,N
         coef(i) = coef(i) / (float(N)/2.)
      enddo

      mean = coef(1)/2.

      do 950  i = 1, numco-1
       a(i) = coef((i)*2)
       b(i) = -coef((i)*2+1)
       v(i) = (a(i)**2 + b(i)**2) / 2.0
!    Note that the variance of a sine or cosine wave is 1/2
       totvar = totvar + v(i)
 950  continue

        if (float(N/2).eq.(float(N)/2.)) then
! get 'a' (cos coef) for the Nyquist frequency, valid if n is even.
         a(numco) = coef(2*numco) / 2.0
         b(numco) = 0.0
         v(numco) = a(numco) ** 2
         totvar = totvar + v(numco)
        else
! get 'a' (cos coef) and 'b' (sin coef) for the Nyquist
! frequency, valid if N is odd.
         a(numco) = coef(2*numco)
         b(numco) = coef(2*numco+1)
         v(numco) = (a(numco)**2 + b(numco)**2) / 2.0
         totvar = totvar + v(numco)
        endif

 970   continue
      return
      END

!-----------------------------------------------------------------
      SUBROUTINE  AUTO  (TS, N, NT, LAG, R)
 
!        THE AUTOCORRELATION COEFFICIENT FOR THE GIVEN LAG IS
!        CALCULATED.  SEE MITCHELL, ET AL., 1966, P. 60.
 
      DIMENSION  TS(N)
 
      REAL*8  SUM1, SUM2, SUM3, SUM4, SUM5
      INTEGER  NTEMP1, NTEMP2, NTEMP3, LAG,NT
 
      NTEMP1 = NT - LAG
 
      SUM1 = 0.0
      SUM2 = 0.0
      SUM3 = 0.0
      SUM4 = 0.0
      SUM5 = 0.0
 
 
      DO 2970  I = 1, NTEMP1
         NTEMP2 = I + LAG
         SUM1 = SUM1 + TS(I) * TS(NTEMP2)
         SUM2 = SUM2 + TS(I)
         SUM4 = SUM4 + TS(I) ** 2
2970  CONTINUE
 
      NTEMP3 = LAG + 1
      DO 2980  I = NTEMP3, NT
         SUM3 = SUM3 + TS(I)
         SUM5 = SUM5 + TS(I) ** 2
2980  CONTINUE
 
      R = ((N-LAG) * SUM1 - SUM2 * SUM3) / (SQRT ((N-LAG) * SUM4 - &
          SUM2 ** 2) * SQRT ((N-LAG) * SUM5 - SUM3 ** 2))
 
!     write(*,2990) LAG, R
2990  FORMAT ('0AUTOCORRELATION COEF, LAG ',I3,' = ', F10.7)
 
 
      RETURN
      END
 
!------------------------------------------------------------------
 
      SUBROUTINE  REDNO (RN, N, R, totvar)
 
 
!        THE RED NOISE SPECTRUM FOR THE GIVEN LAG 1 AUTOCORRELATION
!        COEFFICIENT IS CALCULATED.  SEE GILMAN, ET AL., JAS, 1963.
 
      DIMENSION  RN (N)
 
      REAL  SBAR
 
      PI = 3.141592654

!     SBAR = 1.0 / FLOAT (N)
      SBAR = totvar / FLOAT (N)
 
      DO 3000  I = 1, N
         RN(I) = SBAR * (1 - R**2) / (1 + R**2 - 2 * R * &
                 COS (PI * FLOAT(I) / FLOAT(N)))
3000  CONTINUE
 
      RETURN
      END
 
!----------------------------end of program---------------------------------

