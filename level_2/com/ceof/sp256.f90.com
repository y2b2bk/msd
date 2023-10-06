      program pcspectrum
      implicit none


! Like pcspectrum.f, except input is from a "createdPCs" file instead of
! an EOF-output file.
!
! Spectrum is computed for 6-month segments (parts), padded with zeroes to 256 days.
! The power from each segment is averaged. 
!
! For the red-noise spectrum, which is a function of the lag-1 autocorrelation,
! the lag-1 autocorrelation is an average of the value from all segments (parts).

      integer MAXTIME,NS,NPC,nyr
      parameter (MAXTIME=10000)   ! 23+ yrs
      parameter (NS=183)          ! Number of days per segment
      parameter (NPC=2)           ! 2 PCs
      parameter (nyr = num_r)
      integer MT,num
      integer nyi(MAXTIME),nmi(MAXTIME),ndi(MAXTIME)
      real pc(MAXTIME,NPC)
      integer imd,itseg(MAXTIME), t, is, n_year, iy

      integer year1, leap, linux
      parameter (year1 = beg_year, leap = leap_year)
      parameter (linux = linux_recl)
      integer yy, dd, nod, it, skip, nseg

      integer NT
      parameter (NT=256)  ! enough for 6 month segments
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
      data FOUT &
      /'homedir/level_2/mjo_var/sp256.ts'/

      if (NT/2..ne.float(NT/2)) then
       print*,'make NT divisible by 2 - STOP'
       STOP
      endif

! Input
      open(1,file=&
      'homedir/level_2/mjo_var/ceof.ts.pr',&
        access='direct',&
        form='unformatted',recl=1*linux,status='old')

! Output
      open(11,file=trim(FOUT)//'01',status='unknown')
      open(12,file=trim(FOUT)//'02',status='unknown')

      open(21,file=trim(FOUT)//'01.var',status='unknown')
      open(22,file=trim(FOUT)//'02.var',status='unknown')

!  --------------------
!    Compute spectra of the PCs for each NS-long segment

      DO 88 imd=1,NPC

      nseg  = 0

      call rffti(NT,wsave)   ! initialize

       do i=1,NT/2
        vvAV(i,imd)=0.
       enddo
       r1AV(imd)=0. 

      do 2003 is= 1,2

! winter
        if (is.eq.1) then 
          n_year = nyr-1
! summer
        elseif (is.eq.2) then
          n_year = nyr
        endif

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

      elseif (leap.eq.2) then

       nod = 365

        if (is.eq.1) then
         skip = 304
        elseif (is.eq.2) then
         skip = 120
        endif

      endif

       nseg = nseg + 1

      do 20 t=1,NS

       if (leap.eq.1) then

           it = dd + skip + t

        elseif (leap.eq.2) then

           it = nod*(iy-1)+skip+t

        endif

         read(1,rec=10*(it-1)+imd) ts(t)

  20  continue

        call detrend(ts,NT,1,NS)
!      Apply a tapering to the first and last 10 days by multiplication
!      by a segment of the cosine curve so that the ends of the series
!      taper towards zero (mean has been removed anyway)! Rest is padded
!      with zeroes.
        call tapertozero(ts,NT,1,NS,10)
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

  88   CONTINUE

      do 109, imd=1,NPC

!      calculate power spectrum of lag-1 autoregressive process.
       call REDNO(vredno,NT/2,r1AV(imd),totvarAV(imd))

!  ***Plot of Spectrum
       v3080=0.
       v3080red=0.          
       do i=1,NT/2
        ff(i)=float(i)/float(NT)
        vv(i)=vvAV(i,imd)
        if (ff(i).ge.(1./80.).and.ff(i).le.(1/30.)) then
         v3080=v3080+vvAV(i,imd)
         v3080red=v3080red+vredno(i)
        endif
       enddo
!      smooth spectrums
!      do i=1,10
!       call smooth121(vv,NT/2,NT/2)
!       call smooth121(vredno,NT/2,NT/2)
!      enddo
!      multiply variance by frequency to have area-conserving....
       do i=1,NT/2
        vv(i)=vv(i)*ff(i)
        vredno(i)=vredno(i)*ff(i)
       enddo
!     calculate fraction variance in the 30 to 80-day band.
       v3080=v3080/totvarAV(imd)
       v3080red=v3080red/totvarAV(imd)
       print*,'variance in 30-80 day band=',v3080
       print*,'variance in 30-80 day band for redno=',v3080red
        do 111 i = 1, NT/2
111     write(10+imd,22) i, ff(i),vv(i),vredno(i)
22      format(i5,1x,3e13.5)
        write(20+imd,32) v3080*100, v3080red*100
        write(20+imd,32) v3080*100, v3080red*100
        write(20+imd,32) v3080*100, v3080red*100
32      format(2f13.2)

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
       subroutine detrend(X2,nx,vmi,nv)
       implicit none

! Removes the linear-squares best fit line for the series.
! Only the data from vmi to vmi+nv-1 is deemed useful, and
! the rest is zeroed. (There are nv points of useful data)
! The line of best fit is given by X2' = a + bX1.
! The X1s are assumed to be evenly spaced ( i.e. X1=float(i) )
!
! m1 = mean of X1
! m2 = mean of X2
! m3 = mean of (X1*X2)
! m4 = mean of (X1*X1)
! m5 = mean of (X2*X2)

       integer nv,i,nx,vmi
       real X2(nx),m1,m2,m3,m4,m5,r,a,b

       if (vmi+nv-1.gt.nx) then
        print*,'ERROR as vmi+nv-1 > nx'
        STOP
       endif

       m1=0.
       m2=0.
       m3=0.
       m4=0.
       m5=0.

       do 10 i = vmi,vmi+nv-1
        m1 = m1+float(i)/float(nv)
        m2 = m2+X2(i)/float(nv)
        m3 = m3+(float(i)*X2(i))/float(nv)
        m4 = m4+(float(i)*float(i))/float(nv)
        m5 = m5+(X2(i)*X2(i))/float(nv)
  10   continue

       r=(m3-m1*m2)/(sqrt(m4-m1**2)*sqrt(m5-m2**2))
       b=(m3-m1*m2)/(m4-m1**2)
       a=m2-b*m1

       do 20 i = vmi,vmi+nv-1
        X2(i) = X2(i) - (a + b*float(i))
  20   continue
!      print*,'Trend line has a=',a,' b=',b

       if (vmi.gt.1.) then
        do 15 i = 1,vmi-1
         X2(i) = 0.
  15    continue
       endif
       if (vmi+nv.le.nx) then
        do 25 i = vmi+nv,nx
         X2(i) = 0.
  25    continue
       endif

       return
       end

!-----------------------------------------------------------------
       subroutine tapertozero(ts,N,nmi,nn,tp)
       implicit none

! "taper" the first and last 'tp' members of 'ts' by multiplication by
! a segment of the cosine curve so that the ends of the series
! taper toward zero. This satisfies the
! periodic requirement of the FFT.
! Only the data from nmi to nmi+nn-1 is deemed useful, and
! the rest is set to zero. (There are nn points of useful data)
       integer i,j,N,tp,nmi,nn
       real Pi,ts(N)
       parameter (Pi=3.1415926)   !tp is number to taper on each end.

       if (N.lt.tp*2.or.nn.lt.tp*2) then
        print*,'No use doing the tapering if less than tp*2 values!'
        STOP
       endif
       if (nmi+nn-1.gt.N) then
        print*,'ERROR as nmi+nn-1 > N'
        STOP
       endif

       do i=1,N
        j=i-nmi+1
        if (j.le.0.or.j.gt.nn) then
         ts(i)=0.
        elseif (j.le.tp) then
         ts(i)= ts(i)*.5*(1.-COS((j-1)*Pi/float(tp)))
        elseif (j.gt.(nn-tp).and.j.le.nn) then
         ts(i)= ts(i)*.5*(1.-COS((nn-j)*Pi/float(tp)))
        else
         ts(i)= ts(i)
        endif
       enddo

       return
       end
!-----------------------------------------------------------------

      subroutine smoothrm(vv,vn,nn,pts)
      implicit none
! Smooths vv by passing it through a pts-point running mean.
! Towards the beginning and end of the series the number of points
! is reduced and it is also the case that the total sum is conserved.
! There are 'nn' pieces of useful information, which may be less
! than or equal to 'vn'.
!  Make sure pts is ODD.
      integer nn,pts,i,j,hpts,vn 
      real vv(vn),dum(5000)

      if(float(pts/2).eq.float(pts)/2.) then
       print*,'pts should be odd, STOPPING'
       STOP
      endif
      hpts = (pts-1)/2
      do i=1,hpts
       dum(i)=0.
       do j=1,(hpts-i+1)
        dum(i)=dum(i)+2.*vv(j)/float(pts) 
       enddo
       do j=hpts-i+2,hpts+i
        dum(i)=dum(i)+vv(j)/float(pts) 
       enddo
      enddo
      do i=(hpts+1),(nn-hpts)
       dum(i)=0.
       do j=i-hpts,i+hpts
        dum(i)=dum(i)+vv(j)/float(pts)
       enddo
      enddo
      do i=(nn-hpts+1),nn
       dum(i)=0.
       do j=(i-hpts),(2*nn-i-hpts)
        dum(i)=dum(i)+vv(j)/float(pts)
       enddo
       do j=(2*nn-i-hpts+1),nn
        dum(i)=dum(i)+2.*vv(j)/float(pts)
       enddo
      enddo

      do i=1,nn
       vv(i)=dum(i)
      enddo
      RETURN
      END

!-----------------------------------------------------------------
      subroutine smooth121(vv,vn,nn)
      implicit none
! Smooths vv by passing it through a 1-2-1 filter.
! The first and last points are given 3-1 (1st) or 1-3 (last)
! weightings (Note that this conserves the total sum).
! The routine also skips-over missing data (assigned to be
! a value of 1.E36).
! There are 'nn' pieces of useful information, which may be less
! than or equal to 'vn'.

      integer nn,i,vn
      real spv,vv(vn),dum(5000)

      if (nn.gt.5000) then
       print*,'need to increase 5000 in smooth121.f'
       STOP
      endif

      spv=1.E36
      i=0
 10   continue
      i=i+1
      if (vv(i).eq.spv) then
       dum(i)=spv
      elseif(i.eq.1.or.vv(i-1).eq.spv) then
       dum(i)=(3.*vv(i)+vv(i+1))/4.
      elseif(i.eq.nn.or.vv(i+1).eq.spv) then
       dum(i)=(vv(i-1)+3.*vv(i))/4.
      else
       dum(i)=(1.*vv(i-1)+2.*vv(i)+1.*vv(i+1))/4.
      endif
      if (i.ne.nn) goto 10

      do i=1,nn
       vv(i)=dum(i)
      enddo
      RETURN
      END


!------------------------------------------------------------------
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
 
      R = ((N-LAG) * SUM1 - SUM2 * SUM3) / (SQRT ((N-LAG) * SUM4 -&
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
         RN(I) = SBAR * (1 - R**2) / (1 + R**2 - 2 * R *&
                 COS (PI * FLOAT(I) / FLOAT(N)))
3000  CONTINUE
 
      RETURN
      END
 
!----------------------------end of program---------------------------------

