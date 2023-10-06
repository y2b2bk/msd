      program spacetimeCross
      implicit none
 
! This version set-up for datasets on standard 2.5 degree grid.
 
! Calculates the Co- and Quadrature spectrum between 2 fields
! that have information in both space and time...........
 
! N.b. this program has been written to use only a small amount
! of RAM.....thus the dataset is read-in NLAT times during it.
 
! EE(n,t) = the initial (real) data set that later becomes the
!         (complex) space-time spectrum
! PEE(n,t) = the (real) power spectrum (separated into eastward and westward)
! ss() and ff() are arrays of wavenumbers and frequencies (cycles per day)
!          corresponding to PEE(,)
! totvar = the total variance of the dataset (about the global mean)
! globmean = the global time mean (average in space and time)
! P12(n,t) = co-spectrum                   |
! Q12(n,t) = quadrature spectrum           | All real numbers
! Coh2(n,t) = coherence-squared statistic  | On same grid as PEE(n,t)
! Phas(n,t) = Phase    (in radians)        |                   
!
! Like gridspectparts.f this program calculates the space-time
! spectra for many parts of a longer (say 10 yr) time series.
! Each part is of length NT and is separated by NP time steps.
! The longitudinal domain of the S-T spectra may be restricted
! using the variables xlonw and xlone. Note that tapering in
! space and time is done to make the datasets periodic.
! The calculations are also only made for the latitudes
! between sout and nout. Also note that all longitudes
! are still kept for the calculation so that every planetary
! wavenumber will be represented.
!
! Plotting is done later by the routine frqxwnST.f
!
! OUTPUT is of the form.
!   NT,NL,xlonw,xlone,sout,nout   !>
!   (ff(t),t=1,NT+1)              !>        A HEADER
!   (ss(n),n=1,NL+1)              !> 
!   lat
!   do lat=sout,nout
!    ((PEE1sum(n,t),n=1,NL+1),t=1,NT+1)    
!    ((PEE2sum(n,t),n=1,NL+1),t=1,NT+1)   
!    ((P12sum(n,t),n=1,NL+1),t=1,NT+1)  
!    ((Q12sum(n,t),n=1,NL+1),t=1,NT+1)
!   enddo
!  WHERE
!  NT = number of times of input (can be even or odd!)
!  NT = number of frequency bins of variance
!  NL = number of spatial bins of variance (probably 144)
!  xlonw = western longitude that will be forced to zero
!  xlone = eastern longitude that will be forced to zero
!  sout to nout are the bounding latitudes for the output.
!  ff(t) are the frequencies in cycles per day.
!  ss(n) are the planetary zonal wavenumbers.
!  P12(n,t,lat) and Q12(n,t,lat) are averaged over the many parts.
                                                      
! VARIABLES ASSOCIATED WITH THE FFT
      integer NT,NP,PP,itr,NL, NM, ip, m
! Make NT and NL EVEN numbers as it is easier that way!!
      parameter (NT=num_s)  ! Length of 'part' to be FFTed
      parameter (NL=num_x)  ! Remember that NLON repeats the first longitude
      parameter (NM=sel_y, PP=tot_s)

      real olr(NL,NM,NT), u850(NL,NM,NT)

! VARIABLES ASSOCIATED WITH THE INTERNAL PROCESSING IN THIS PROGRAM
      integer j,tt,lat,lon,lon2,Pcount,n,t,pn,pt
      real WSAVE1(4*NL+15),WSAVE2(4*NT+15)
      real ts1(NT),ts2(NT),ls1(NL),ls2(NL)
      complex EE1(NL,NT),EEo1(NL,NT),CEEa(NL),CEEb(NT)
      complex EE2(NL,NT),EEo2(NL,NT)
      real globmean,globmean2,totvar,totvar2
      real frq(NT/2-1)

! OUTPUT VARIABLES
      real ff(NT+1),ss(NL+1)
      real PEE1sum_sym(NL+1,NT/2+1),PEE2sum_sym(NL+1,NT/2+1)
      real PEE1sum_asy(NL+1,NT/2+1),PEE2sum_asy(NL+1,NT/2+1)
      real P12sum_sym(NL+1,NT/2+1),Q12sum_sym(NL+1,NT/2+1)
      real P12sum_asy(NL+1,NT/2+1),Q12sum_asy(NL+1,NT/2+1)
      real Coh2_sym(NL+1,NT/2+1),Phas_sym(NL+1,NT/2+1)
      real Coh2_asy(NL+1,NT/2+1),Phas_asy(NL+1,NT/2+1)
      real v1_sym(NL+1,NT/2+1),v2_sym(NL+1,NT/2+1)
      real v1_asy(NL+1,NT/2+1),v2_asy(NL+1,NT/2+1)

!   INPUT FILES

      open(11,file='homedir/level_2/coh2/olr_name/data/&
      seg256_over206_sym_asy.gdat', &
      recl=NL*NM*recl_linux, access='direct', &
           form='unformatted',status='old')

      open(12,file='homedir/level_2/coh2/variable/data/&
      seg256_over206_sym_asy.gdat', &
      recl=NL*NM*recl_linux, access='direct', &
           form='unformatted',status='old')

!   OUTPUT FILE
      open(21,file='homedir/level_2/coh2/&
      variable/power/power.sym.gdat', recl=(NL+1)*(NT/2+1)*recl_linux,&
       access='direct',&
      form='unformatted',status='unknown')

      open(22,file='homedir/level_2/coh2/&
      variable/power/power.asy.gdat', recl=(NL+1)*(NT/2+1)*recl_linux,&
      access='direct',&
      form='unformatted',status='unknown')

      open(31,file='homedir/level_2/coh2/&
      variable/power/coh2.sym.gdat', recl=(NL+1)*(NT/2+1)*recl_linux,& 
      access='direct',&
      form='unformatted',status='unknown')

      open(32,file='homedir/level_2/coh2/&
      variable/power/coh2.asy.gdat', recl=(NL+1)*(NT/2+1)*recl_linux,&
      access='direct',&
      form='unformatted',status='unknown')

!--------------------------------------------------------------------
!------------------------MAIN PROGRAM--------------------------------
! EE(n,t) = the initial (real) data set that later becomes the
!         (complex) space-time spectrum
! ss() and ff() are arrays of wavenumbers and frequencies (cycles per day)
!          corresponding to PEE( )    

      if(float(NT/2).ne.float(NT)/2.) then
       print*,'NT must be even, it is probably more efficient that way'
       STOP
      elseif(float(NL/2).ne.float(NL)/2.) then
       print*,'NL must be even'
       STOP
      endif


! WRITE HEADER TO OUTPUT
      do t=1,NT+1
       ff(t) = float(t-1-NT/2)/float(NT)    ! in cycles per day.
      enddo
      do n=1,NL+1
       ss(n) = float(n-1-NL/2)
      enddo

! Initialize SUM arrays
! out of bounds subscript: noticed from Dr. Dennis Shea at NCAR
!      do t=1,NT+1
       do t=1,NT/2+1
       do n=1,NL+1
        PEE1sum_sym(n,t)=0.
        PEE2sum_sym(n,t)=0.
        P12sum_sym(n,t)=0.
        Q12sum_sym(n,t)=0.

        PEE1sum_asy(n,t)=0.
        PEE2sum_asy(n,t)=0.
        P12sum_asy(n,t)=0.
        Q12sum_asy(n,t)=0.
       enddo
       enddo
!***************HERE IS THE BIG LOOP********************************** 
      do 2007 ip=1,PP

! read
      do t=1,NT
         read(11,rec=(ip-1)*NT+t) ((olr(n,m,t),n=1,NL),m=1,NM)
         read(12,rec=(ip-1)*NT+t) ((u850(n,m,t),n=1,NL),m=1,NM)
      enddo

! Do a loop in latitude!! - average
      do m = 1, NM


      do 100 t=1,NT
      do 100 n=1,NL
         EE1(n,t) = olr(n,m,t)  
         EE2(n,t) = u850(n,m,t)  
 100  continue

! Initialize FFTs
      call cffti(NL,WSAVE1)
      call cffti(NT,WSAVE2)

!--------------------------------------------------------------------
!---------------COMPUTING SPACE-TIME SPECTRUM for EE1----------------

      do 201 t=1,NT
       do 151 n=1,NL
        CEEa(n) = EE1(n,t)
! CEEa(n) contains the grid values around a latitude circle
 151   continue
       call cfftf(NL,CEEa,WSAVE1)
       do 171 n=1,NL
        EE1(n,t) = CEEa(n)/float(NL)
 171   continue
 201  continue

! Now the array EE(n,t) contains the Fourier coefficients (in planetary
! wavenumber space) for each time.

      do 300 n=1,NL
       do 251 t=1,NT
        CEEb(t) = EE1(n,t)
! CEEb(t) contains a time-series of the coefficients for a single
! planetary zonal wavenumber
 251   continue
       call cfftf(NT,CEEb,WSAVE2)
       do 270 t=1,NT
        EE1(n,t) = CEEb(t)/float(NT)
 270   continue
 300  continue

! Now the array EE1(n,t) contains the space-time spectrum.

!--------------------------------------------------------------------
!---------------COMPUTING SPACE-TIME SPECTRUM for EE2----------------

      do 202 t=1,NT
       do 152 n=1,NL
        CEEa(n) = EE2(n,t)
! CEEa(n) contains the grid values around a latitude circle
 152   continue
       call cfftf(NL,CEEa,WSAVE1)
       do 172 n=1,NL
        EE2(n,t) = CEEa(n)/float(NL)
 172   continue
 202  continue

! Now the array EE(n,t) contains the Fourier coefficients (in planetary
! wavenumber space) for each time.

      do 302 n=1,NL
       do 252 t=1,NT
        CEEb(t) = EE2(n,t)
! CEEb(t) contains a time-series of the coefficients for a single
! planetary zonal wavenumber
 252   continue
       call cfftf(NT,CEEb,WSAVE2)
       do 272 t=1,NT
        EE2(n,t) = CEEb(t)/float(NT)
 272   continue
 302  continue

! Now the array EE2(n,t) contains the space-time spectrum.
                               
!-------------------------------------------------------------------

! Create array PEE(NL+1,NT+1) which contains the (real) power spectrum.
! In this array, the negative wavenumbers will be from pn=1 to NL/2;
! The positive wavenumbers will be for pn=NL/2+2 to NL+1.
! Negative frequencies will be from pt=1 to NT/2.
! Positive frequencies will be from pt=NT/2+2 to NT+1.
! Information about zonal mean will be for pn=NL/2+1.
! Information about time mean will be for pt=NT/2+1.
! Information about the Nyquist Frequency is at pt=1 and pt=NT+1
! In PEE, I define the WESTWARD waves to be either +ve frequency
! and -ve wavenumber or -ve freq and +ve wavenumber.
! EASTWARD waves are either +ve freq and +ve wavenumber OR -ve
! freq and -ve wavenumber.

! original one
!     do 191 pt=1,NT+1
!      do 189 pn=1,NL+1
!       if(pn.le.NL/2) then
!        n=NL/2+2-pn
!        if(pt.le.NT/2) then
!         t=NT/2+pt
!        else
!         t=pt-NT/2
!        endif
!       elseif(pn.ge.NL/2+1) then
!        n=pn-NL/2
!        if (pt.le.NT/2+1) then
!         t=NT/2+2-pt
!        else
!         t=NT+NT/2+2-pt
!        endif
!       endif

      do pt=1,NT/2+1

       do pn=1,NL+1

       if(pn.le.NL/2) then
        n=NL/2+2-pn
        t=pt
       elseif(pn.eq.NL/2+1) then
        n=1
        t=pt
       elseif(pn.ge.NL/2+2) then
        n=pn-NL/2
        if (pt.eq.1) then
         t=pt
        else
         t=NT+2-pt
        endif
       endif

      if (m.ge.1.and.m.le.(NM/2+1)) then
  
        PEE1sum_sym(pn,pt)=PEE1sum_sym(pn,pt)&
      +(CABS(EE1(n,t)))**2 /float(PP*(NM/2+1))
        PEE2sum_sym(pn,pt)=PEE2sum_sym(pn,pt)&
      +(CABS(EE2(n,t)))**2 /float(PP*(NM/2+1))

        P12sum_sym(pn,pt)=P12sum_sym(pn,pt)&
      +REAL(CONJG(EE1(n,t))*EE2(n,t))/float(PP*(NM/2+1))
        Q12sum_sym(pn,pt)=Q12sum_sym(pn,pt)&
      +REAL((0.,1.)*CONJG(EE1(n,t))*EE2(n,t))/float(PP*(NM/2+1))

      else

        PEE1sum_asy(pn,pt)=PEE1sum_asy(pn,pt)&
      +(CABS(EE1(n,t)))**2 /float(PP*(NM/2))
        PEE2sum_asy(pn,pt)=PEE2sum_asy(pn,pt)&
      +(CABS(EE2(n,t)))**2 /float(PP*(NM/2))

        P12sum_asy(pn,pt)=P12sum_asy(pn,pt)&
      +REAL(CONJG(EE1(n,t))*EE2(n,t))/float(PP*(NM/2))
        Q12sum_asy(pn,pt)=Q12sum_asy(pn,pt)&
      +REAL((0.,1.)*CONJG(EE1(n,t))*EE2(n,t))/float(PP*(NM/2))

      endif
 
      enddo
      enddo

   
!     do pt=1,NT+1
!     do pn=1,NL+1
!      Coh2(pn,pt)=(P12sum(pn,pt)**2+Q12sum(pn,pt)**2)/
!    #                        (PEE1sum(pn,pt)*PEE2sum(pn,pt))
!      Phas(pn,pt)=ATAN(Q12sum(pn,pt)/P12sum(pn,pt))
!     enddo
!     enddo

      enddo

 2007 continue         
!***************END BIG LOOP HERE*****************************  
! write
       write(21,rec=1) ((PEE1sum_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(21,rec=2) ((PEE2sum_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(21,rec=3) ((P12sum_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(21,rec=4) ((Q12sum_sym(n,t),n=1,NL+1),t=1,NT/2+1)

       write(22,rec=1) ((PEE1sum_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(22,rec=2) ((PEE2sum_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(22,rec=3) ((P12sum_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(22,rec=4) ((Q12sum_asy(n,t),n=1,NL+1),t=1,NT/2+1)

! ********* APLLY SMOOTHING TO THE SPECTRUM ************************
! Apply smoothing to PEE1,PEE2,P12, and Q12 before calculating Coh2 and Phase.
! Smoothing in frq only
      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=PEE1sum_sym(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        PEE1sum_sym(n,t)=frq(t-4+1)
       enddo
      enddo

      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=PEE2sum_sym(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        PEE2sum_sym(n,t)=frq(t-4+1)
       enddo
      enddo
 
      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=P12sum_sym(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        P12sum_sym(n,t)=frq(t-4+1)
       enddo
      enddo

      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=Q12sum_sym(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        Q12sum_sym(n,t)=frq(t-4+1)
       enddo
      enddo

! asymmetric
      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=PEE1sum_asy(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        PEE1sum_asy(n,t)=frq(t-4+1)
       enddo
      enddo

      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=PEE2sum_asy(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        PEE2sum_asy(n,t)=frq(t-4+1)
       enddo
      enddo
 
      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=P12sum_asy(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        P12sum_asy(n,t)=frq(t-4+1)
       enddo
      enddo

      do n=1, NL+1
       do t=4,NT/2-1
        frq(t-4+1)=Q12sum_asy(n,t)
       enddo
       call smooth121(frq,NT/2-1,NT/2-1)
       do t=4,NT/2-1
        Q12sum_asy(n,t)=frq(t-4+1)
       enddo
      enddo


! Calculate the Coherence-squared statistic and the phase.
       do t=1,NT/2+1
       do n=1,NL+1
!       if (PEE1sum_sym(n,t).ne.dmiss) then
         Coh2_sym(n,t)=(P12sum_sym(n,t)**2+Q12sum_sym(n,t)**2)/&
                              (PEE1sum_sym(n,t)*PEE2sum_sym(n,t))
         Phas_sym(n,t)=ATAN(Q12sum_sym(n,t)/P12sum_sym(n,t))
         if(n.le.NL/2+1) then
          v1_sym(n,t)=Q12sum_sym(n,t)/&
                       sqrt(Q12sum_sym(n,t)**2+P12sum_sym(n,t)**2)
         else
          v1_sym(n,t)=-1.*Q12sum_sym(n,t)/&
                       sqrt(Q12sum_sym(n,t)**2+P12sum_sym(n,t)**2)
          Q12sum_sym(n,t)=-1.*Q12sum_sym(n,t)
         endif
         v2_sym(n,t)=P12sum_sym(n,t)/&
                       sqrt(Q12sum_sym(n,t)**2+P12sum_sym(n,t)**2)
!       else
!        Coh2_sym(n,t)=dmiss
!        Phas_sym(n,t)=dmiss
!       endif

        if (Coh2_sym(n,t).lt..05) then
         v1_sym(n,t)=0.0
         v2_sym(n,t)=0.0
        endif
       enddo
       enddo

       do t=1,NT/2+1
       do n=1,NL+1
!       if (PEE1sum_asy(n,t).ne.dmiss) then
         Coh2_asy(n,t)=(P12sum_asy(n,t)**2+Q12sum_asy(n,t)**2)/&
                              (PEE1sum_asy(n,t)*PEE2sum_asy(n,t))
         Phas_asy(n,t)=ATAN(Q12sum_asy(n,t)/P12sum_asy(n,t))
         if(n.le.NL/2+1) then
          v1_asy(n,t)=Q12sum_asy(n,t)/&
                       sqrt(Q12sum_asy(n,t)**2+P12sum_asy(n,t)**2)
         else
          v1_asy(n,t)=-1.*Q12sum_asy(n,t)/&
                       sqrt(Q12sum_asy(n,t)**2+P12sum_asy(n,t)**2)
          Q12sum_asy(n,t)=-1.*Q12sum_asy(n,t)
         endif
         v2_asy(n,t)=P12sum_asy(n,t)/&
                       sqrt(Q12sum_asy(n,t)**2+P12sum_asy(n,t)**2)
!       else
!        Coh2_asy(n,t)=dmiss
!        Phas_asy(n,t)=dmiss
!       endif

        if (Coh2_asy(n,t).lt..05) then
         v1_asy(n,t)=0.0
         v2_asy(n,t)=0.0
        endif
       enddo
       enddo

       write(31,rec=1) ((Coh2_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(31,rec=2) ((Phas_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(31,rec=3) ((v1_sym(n,t),n=1,NL+1),t=1,NT/2+1)
       write(31,rec=4) ((v2_sym(n,t),n=1,NL+1),t=1,NT/2+1)

       write(32,rec=1) ((Coh2_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(32,rec=2) ((Phas_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(32,rec=3) ((v1_asy(n,t),n=1,NL+1),t=1,NT/2+1)
       write(32,rec=4) ((v2_asy(n,t),n=1,NL+1),t=1,NT/2+1)
      STOP
      END   !main program                                    

!----------------------------------------------------------------------------
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

      spv=-999.
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
