      program cross1d
      implicit none

! For calculating and plotting cross spectra between the PCs.
! This computation *may* be restricted to SS or NS only. Search on NS and SS.
      integer tmax
      parameter (tmax = num_t)

      integer linux
      parameter (linux = linux_recl)

      integer me,MAXSPAC,MAXTIME
!    Choose the following based on the size of the read-in nspace and NT
      parameter (MAXSPAC=2000,MAXTIME=tmax)
      integer NX,NY,NT,nspace,fstyr
      integer nyi(MAXTIME),nmi(MAXTIME),ndi(MAXTIME)
      real pc(MAXTIME,20)
      integer imd,imd1,imd2,isp,it,itdum,ll
!    Choose the 2 PCs to calculate a cross-spectrum for.
      parameter (imd1=1,imd2=2)

      integer i,yr1,yr2
      real vpl,vpr,vpb,vpt,ul,ur,ub,ut,cfux,cfuy,pos
      character dd2*2,dd2a*2,dd3*3,dd4*4,dd4a*4
      character*100 FOUT
      data FOUT &
      /'homedir/level_2/mjo_var/crsp'/

!    variables for complex FFT
      integer pt,nsum
      complex EE1(MAXTIME),EE2(MAXTIME)
      real WSAVE(4*MAXTIME+15)
      real PEE1(MAXTIME/2+1),PEE2(MAXTIME/2+1)   ! power spectra
      real P12(MAXTIME/2+1),Q12(MAXTIME/2+1)  ! co- and quadrature spectrum
      real Coh2(MAXTIME/2+1),Phas(MAXTIME/2+1) ! Coherence-squared and Phase
      real ff(MAXTIME/2+1)    ! frequencies in cpd
      real v1(MAXTIME/2),v2(MAXTIME/2)
      real Pi,Coh2av        ! Coh2 averaged between 30 and 80 days.
      parameter (Pi=3.1415926)
      character season*2
      parameter (season='AS')
!     parameter (season='NS')
!     parameter (season='SS')

      if (MAXTIME/2..ne.float(MAXTIME/2)) then
       print*,'make MAXTIME divisible by 2 - STOP'
       STOP
      endif

! Input
      open(1,file=&
      'homedir/level_2/mjo_var/ceof.ts',&
         access='direct',&
         form='unformatted',recl=1*linux,status='old')

! Output
      open(11,file=trim(FOUT),status='unknown')
      open(12,file=trim(FOUT)//'.mcoh',status='unknown')

!------------------------------------------------------------------------

      do 20 imd = 1, 2
      do 20 it=1,tmax
         read(1,rec=10*(it-1)+imd) pc(it,imd)
  20  continue

!-----------------------------------------------------------------------
!   Assign EE1 and EE2 to be 2 of the PCs
!-----------------------------------------------------------------------
!     itdum=0
      do it=1,tmax
!      if(season.eq.'SS'.and.(nmi(it).ge.11.or.nmi(it).le.4)) then
!       itdum=itdum+1
!       EE1(itdum)=CMPLX(pc(it,imd1))
!       EE2(itdum)=CMPLX(pc(it,imd2))
!      elseif(season.eq.'NS'.and.nmi(it).le.10.and.nmi(it).ge.5) then
!       itdum=itdum+1
!       EE1(itdum)=CMPLX(pc(it,imd1))
!       EE2(itdum)=CMPLX(pc(it,imd2))
!      elseif(season.eq.'AS') then
!       itdum=itdum+1
! the sign is adjusted here to be consistent with EOFs
        EE1(it)=CMPLX( pc(it,imd1))
        EE2(it)=CMPLX(-pc(it,imd2))
!      endif
      enddo

!-----------------------------------------------------------------------
      call cffti(MAXTIME,WSAVE)                    ! Initialize the FFT
!-----------------------------------------------------------------------

!-------------COMPUTING COMPLEX SPECTRUM for EE1 and EE2----------------

       call cfftf(MAXTIME,EE1,WSAVE)
       do 23 it=1,MAXTIME
        EE1(it) = EE1(it)/float(MAXTIME)
  23   continue

       call cfftf(MAXTIME,EE2,WSAVE)
       do 24 it=1,MAXTIME
        EE2(it) = EE2(it)/float(MAXTIME)
  24   continue

! Create arrays PEE1(MAXTIME/2+1), PEE2, P12, Q12, Coh2.
! Positive frequencies will be from pt=1,MAXTIME/2+1.
! Information about time mean will be for pt=1.
! Information about the Nyquist Frequency is at pt=MAXTIME/2+1
! N.b. PEE1, PEE2, P12, Q12 have their variance spread over both
! positive and negative frequencies. For the comparable variance
! from a real FFT, multiply these values by 2.

      do pt=1,MAXTIME/2+1
       ff(pt)=float(pt-1)/float(MAXTIME)
       PEE1(pt) = (CABS(EE1(pt)))**2
       PEE2(pt) = (CABS(EE2(pt)))**2
       P12(pt) = REAL(CONJG(EE1(pt))*EE2(pt))
       Q12(pt) = REAL((0.,1.)*CONJG(EE1(pt))*EE2(pt))
!      print*,PEE1(pt),PEE2(pt),P12(pt),Q12(pt) 
      enddo

! Smooth PEE1, PEE2, P12, Q12.
! Note that we MUST do this smoothing before calculating the Coherence
! otherwise we get 1.00 for an answer everywhere.
      do i=1,250
       call smooth121(PEE1,MAXTIME/2+1,MAXTIME/2+1)
       call smooth121(PEE2,MAXTIME/2+1,MAXTIME/2+1)
       call smooth121(P12,MAXTIME/2+1,MAXTIME/2+1)
       call smooth121(Q12,MAXTIME/2+1,MAXTIME/2+1)
      enddo

      nsum=0
      Coh2av=0.
      do pt=1,MAXTIME/2+1
       Coh2(pt) = (P12(pt)**2 + Q12(pt)**2) /&
                     ( PEE1(pt) * PEE2(pt) )
       if (P12(pt).gt.0.and.Q12(pt).gt.0) then
        Phas(pt) = ATAN(Q12(pt)/P12(pt))
       elseif (P12(pt).lt.0.and.Q12(pt).gt.0) then
        Phas(pt) = ATAN(Q12(pt)/P12(pt))+Pi
       elseif (P12(pt).lt.0.and.Q12(pt).lt.0) then
        Phas(pt) = ATAN(Q12(pt)/P12(pt))+Pi
       elseif (P12(pt).gt.0.and.Q12(pt).lt.0) then
        Phas(pt) = ATAN(Q12(pt)/P12(pt))+2.*Pi
       endif
!    form mean of Coh2 between 1/80 and 1/30 cpd
       if(ff(pt).ge.1/80..and.ff(pt).le.1/30.) then
        Coh2av = Coh2av + Coh2(pt)
        nsum = nsum + 1 
       endif
!      if(ff(pt).ge.1/20..or.ff(pt).le.1/100.) then
!       Coh2(pt)=1.E36
!       Phas(pt)=1.E36
!      endif
      enddo

       Coh2av=Coh2av/float(nsum)

! Phas
       do pt=1,MAXTIME/2+1
        if (Phas(pt).ne.1.E36) then
         Phas(pt)=Phas(pt)/Pi*180.
        endif
       enddo

        do 111 pt = 1, MAXTIME/2+1

        if (ff(pt).ge.5e-3.and.ff(pt).le.6e-2) then
          write(11,22) pt, ff(pt),Coh2(pt),Phas(pt)
        endif

111   continue
22      format(i5,1x,3e13.5)

          write(12,25) Coh2av
          write(12,25) Coh2av
          write(12,25) Coh2av
25      format(f13.2)

      END   !main program

! --------------------------------------------------------------------------
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
