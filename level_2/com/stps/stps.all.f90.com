      program stps
      implicit none

! This program calculates 2-dim (or wavenumber-frequency) power spectrum
! for a "test" dataset consisting of specified waves and other things.
!--------------------------------------------------------------------
      integer ic,i,t,n,pt,pn,NT,NL
      integer nn, tt, ny, iy
      parameter (NT=num_t,NL=num_x)
      parameter (ny=num_r)

      integer year1, leap, linux, dmax
      parameter (year1 = beg_year, leap = leap_year)
      parameter (linux = linux_recl)   
      parameter (dmax = num_d)
      integer yy, dd, nod, it

      real WSAVE1(4*NL+15),WSAVE2(4*NT+15)
      real EEr(NL,NT),PEE(NL+1,NT+1),globmean,totvar
!     real OEE(NT+1,NL/2+1)
      real OEE(39,11)
      real ave_EEr(NL)
      real zm_EEr(NT)
      real Rd,eif,s,xx,xxm,ll,Pi,g,ps,k,ss(NL+1),ff(NT+1)
      real rand,s2,ps2,k2,eif2

      character*num_cha FOUT
      data FOUT /'variable'/

! EEr(n,t) = the initial (real) data set that is a function of space and time.
! PEE(_,_) = the power spectrum that is a function of wavenumber and freq.
! ss() and ff() are arrays of wavenumbers and frequencies (cycles per day)
!          corresponding to PEE(,)
! NL = Number of longitudes in 'test' dataset
! NT = Number of times in 'test' dataset

!**** Quantities for determination of "test" dataset (consisting of waves).
!**** dimensional quantities are in MKS units.
! s = planetary zonal wavenumber
! k = zonal wavenumber = 2 Pi s / L  (m-1)  
! ps = dimensional phase speed w.r.t. the earth 
! ll = distance around latitude circle (m)
! xx = longitude in degrees
! xxm = longitudinal distance from Greenwich in metres.
! id = time in days  (integer)
! tt = time in seconds (real)
! eif = dimensional frequency of test wave
!--------------------------------------------------------------------
!------------------------MAIN PROGRAM--------------------------------

      Pi = 3.1415926
      g = 9.81
      ll = 2.*Pi*6.37E06           ! at the equator
      globmean = 0.
      totvar = 0.

      open (1, &
     file='homedir/level_1/variable/data/&
     daily.10S10N.period.gdat', form='unformatted',&
     access='direct',recl=nl*linux,status='old')
      open (2, file='variable', form='unformatted',&
!    &access='direct',recl=(NT+1)*(NL/2+1),status='unknown')
     access='direct',recl=39*11*linux,status='unknown')

      OEE = 0.

      yy = year1 - 1
      dd = 0

      do iy = 1, ny
      yy = yy + 1

      globmean = 0.
      ave_EEr = 0.
      zm_EEr = 0.
      totvar = 0.

      if (leap.eq.1) then
       nod = 365
       if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nod = 366
       if (mod(yy,400).eq.0) nod = 366
      elseif (leap.eq.0) then
       nod = dmax
      endif

      do t=1,NT

       if (leap.eq.1) then
        it = dd + t
       elseif (leap.eq.0) then
        it = nod*(iy-1)+t
       endif

      read (1, rec=it) (EEr(n,t),n=1,NL)

      do n = 1, NL
      globmean = globmean + EEr(n,t)/float(NT*NL)
      ave_EEr(n) = ave_EEr(n) + EEr(n,t)/float(NT)
      zm_EEr(t) = zm_EEr(t) + EEr(n,t)/float(NL)
      enddo

      enddo ! t

      do t=1,NT
      do n=1,NL
!      EEr(n,t) = EEr(n,t) - ave_EEr(n) - zm_EEr(t)
!      EEr(n,t) = EEr(n,t) - globmean
       EEr(n,t) = EEr(n,t) - ave_EEr(n)
      enddo
      enddo

      do t=1,NT
      do n=1,NL
!      totvar = totvar + ((EEr(n,t)-globmean)**2)/float(NT*NL)
       totvar = totvar + ((EEr(n,t))**2)/float(NT*NL)
      enddo
      enddo
      print*,'total variance of EEr is',totvar,' globmean is',globmean

!--------------------------------------------------------------------
!------------------COMPUTING SPACE-TIME SPECTRUM---------------------

      call cffti(NL,WSAVE1)      ! Initialize FFT for longitude direction
      call cffti(NT,WSAVE2)      ! Initialize FFT for time direction

      call powerspec2dim(EEr,NL,NT,WSAVE1,WSAVE2,PEE)

! The newly created PEE(NL+1,NT+1) contains the power spectrum.

! The corresponding frequencies, ff, and wavenumbers, ss, are:-
      do t=1,NT+1
       ff(t) = float(t-1-NT/2)/float(NT)    ! in cycles per day.
      enddo
      do n=1,NL+1
       ss(n) = float(n-1-NL/2)          ! in planetary wavenumber
      enddo

!     do n = NL/2+1, NL+1
!      nn = n-NL/2
!     do t = 1, NT+1
!      OEE(t,nn) = PEE(n,t)
!     enddo
!     enddo

      do n = NL/2+1, NL/2+1+10
       nn = n-NL/2
      do t = NT/2+1-19, NT/2+1+19
       tt = -(NT/2+1)+20+t
       OEE(tt,nn) = OEE(tt,nn)+PEE(n,t)/float(ny)
      enddo ! t
      enddo ! n

      if (leap.eq.1) then
       dd = dd + nod
      endif

      enddo ! iy

      write(2, rec=1) OEE

!--------------------------------------------------------------------
!------------             GRADS OUTPUT       ------------------------
!--------------------------------------------------------------------
      open(12,file='variable.ctl',status='unknown')
      write  (12,1234) FOUT,39,(ff(i),i=nt/2+1-19,nt/2+1+19) &
            ,11,(ss(i),i=nl/2+1,nl/2+1+10)
1234  format ('DSET ^',anum_cha/&
              '*'/&
              'UNDEF  -999.'/&
              'TITLE SPCTIME OUTPUT'/&
              '*'/&
              'XDEF ',i4,1x,'LEVELS ',39(1x,f7.3) /&
              '*'/&
              'YDEF ',i4,1x,'LEVELS ',11(1x,f7.3) /&
              '*'/&
              'ZDEF  1 LEVELS   1000.      '/&
              '*'/&
              'TDEF  1 LINEAR 1jan1979 1dy'/&
              '*'/&
              'VARS 1'/&
              'power      0    99   power'/&
              'ENDVARS')

      END

!-----------------------------------------------------------------------
      subroutine powerspec2dim(EEr,NL,NT,WSAVE1,WSAVE2,PEE) 

! Use NCAR's FFTpack routines to compute the two-dimensional power
! spectrum of the input dataset EEr.
!
! The input array EEr(n,t) is a function of two dimensions, e.g.,
! space (n=1 to NL) and time (t=1 to NT).
!
! The output array PEE(pn,pt) is also a function of two dimensions, e.g.,
! wavenumber (pn) and frequency (pt).
! pn varies from 1 to NL+1, and pt from 1 to NT+1.
! And the array PEE will be symmetric about pn=NL/2+1 and pt=NT/2+1.
! Hence only half of PEE needs to be plotted to see all the information.
!
! If the input array EE has as its two dimensions longitude and time,
! then the following applies to the arrangement of the output spectrum.
!   - Power for negative wavenumbers will be for pn=1 to NL/2
!   - Power for the zonal mean (wavenumber 0) will be at pn=NL/2+1
!   - Power for the positive wavenumbers will be for pn=NL/2+2 to NL+1
!   - Power for the Nyquist wavenumber will be at pn=1 and pn=NL+1
!   - Power for negative frequencies will be for pt=1 to NT/2+1
!   - Power for the time mean (frequency=0) will be at pt=NT/2+1
!   - Power for the positive frequencies will be for pt=NT/2+2 to NT+1
!   - Power for the Nyquist frequency will be at pt=1 and pt=NT+1
!   - Westward moving waves will be located in the quadrants defined by
!     +ve frequency and -ve wavenumber, or -ve frequency and +ve wavenumber.
!   - Eastward moving waves are for +ve/+ve, or -ve/-ve.
! For example, the wavenumber 1 eastward moving wave with the frequency of
! the first harmonic will be located at (NL/2+2,NT/2+2) or (NL/2,NT/2)
!
! If the "space" dimension is in the meridional direction, then replace
! "westward" with "southward", and "eastward" with "northward" in the above.
!
! If the two dimensions (n and t) are both spatial, then the above
! will apply to "left" and "right" sloping wave-forms instead.
!
! Prior to calling this subroutine, the following calls to initialization
! routines must be made.
!      call cffti(NL,WSAVE1)
!      call cffti(NT,WSAVE2)   
! These routines only need to be called once for each different value of
! NL or NT for which this power spectrum routine is called.
!
! "totvar" will contain the total variance of the input dataset as computed
!   by the FFTs.
! "mean" will contain the global mean of the input array.

      integer NL,NT,n,t,pn,pt
      real EEr(NL,NT),WSAVE1(4*NL+15),WSAVE2(4*NT+15)
      complex EE(NL,NT),CEE1(NL),CEE2(NT)
      real PEE(NL+1,NT+1)   ! note the unusual dimensions
      real totvar1,totvar2,mean,ptstart,ptend

!*** Big loop over "t", calling FFT
      do 200 t=1,NT
       do 150 n=1,NL
        EE(n,t) = CMPLX(EEr(n,t)) 
        CEE1(n) = EE(n,t)
 150   continue
       call cfftf(NL,CEE1,WSAVE1)
       do 170 n=1,NL
        EE(n,t) = CEE1(n)/float(NL)
 170   continue
 200  continue

!*** Big loop over "n", calling FFT.
      do 300 n=1,NL
       do 250 t=1,NT
        CEE2(t) = EE(n,t)
 250   continue
       call cfftf(NT,CEE2,WSAVE2)
       do 270 t=1,NT
        EE(n,t) = CEE2(t)/float(NT)
 270   continue
 300  continue

! Now the array EE(n,t) contains the (complex) space-time spectrum.

! Create array PEE(NL+1,NT/2+1) which contains the (real) power spectrum.
!  Note how the PEE array is arranged into a different order to EE.
      do 191 pt=1,NT+1
       do 189 pn=1,NL+1
        if(pn.le.NL/2) then
         n=NL/2+2-pn
         if(pt.le.NT/2) then
          t=NT/2+pt
         else
          t=pt-NT/2
         endif
        elseif(pn.ge.NL/2+1) then
         n=pn-NL/2
         if (pt.le.NT/2+1) then
          t=NT/2+2-pt
         else
          t=NT+NT/2+2-pt
         endif
        endif
        PEE(pn,pt) = (CABS(EE(n,t)))**2
 189   continue
 191  continue

!**************************
! The following computations of mean and total variance are useful checks.
! To save processing time, they may be skipped.
!     goto 4000 

! Global mean value is contained in this position of EE array.
      mean = REAL(EE(1,1))
      print*,'Global Mean from the EE(1,1) is',mean

! The total variance of the input dataset equals the sum over
! (almost) all of PEE.
       totvar1=0.
       do pt=1,NT         ! only going to NT, not NT+1
        do pn=1,NL        ! only going to NL, not NL+1
         if(pt.eq.NT/2+1.and.pn.eq.NL/2+1) then 
          continue        ! don't include the global mean in sum
         else
          totvar1=totvar1+PEE(pn,pt)
         endif
        enddo
       enddo
! Alternatively, the total variance equals twice the sum over almost half
! of PEE.
       totvar2=0.
       do pt=1,NT/2+1
        do pn=1,NL        ! only going to NL, not NL+1
         if(pt.eq.NT/2+1.and.pn.eq.NL/2+1) then 
          continue        ! don't include the global mean in sum
         elseif(pt.ne.1.and.pt.ne.NT/2+1) &
             then
!$           Count variance for Nyquist frequency and time mean only once.
!$           Everything else gets multiplied by 2 when I do this sum of the
!$           variance only over half the bins. For this sum, I am taking
!$           advantage of the symmetrical nature of PEE.
          totvar2=totvar2+2.*PEE(pn,pt)
         else
          totvar2=totvar2+PEE(pn,pt)
         endif
        enddo
       enddo
       print*,'Total variance is, two different ways',totvar1,totvar2

4000   continue
!**************************

      END
