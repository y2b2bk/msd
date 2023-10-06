      parameter (NL=num_x,NT=num_s)
      integer pt, pn, i, j, n, t
 
      real yrPEE1(NL+1,NT/2+1), yrPEE2(NL+1,NT/2+1)
      real sumPEE(NL+1,NT/2+1), log_sum(NL+1,NT/2+1)
      real log_sym(NL+1,NT/2+1), log_asy(NL+1,NT/2+1)
      real norm_sym(NL+1,NT/2+1), norm_asy(NL+1,NT/2+1)
      real ff(NT/2+1), ss(NL+1), mm(NL+1), frq(NT/2+1)
      real dmiss
      data dmiss /missing/
      logical olr
      data olr /.torf./

      do pt=1,NT/2+1
       ff(pt)=float(pt-1)/float(NT)
       do pn=1,NL+1
       ss(pn)=float(pn-1-NL/2)
       enddo
      enddo

      open (1,file='homedir/level_2/wk99/variable/&
      power/power.sym.gdat', access='direct',&
         form='unformatted',recl=(NL+1)*(NT/2+1)*linux_recl,&
      status='unknown')

      open (2,file='homedir/level_2/wk99/variable/&
      power/power.asy.gdat', access='direct',&
         form='unformatted',recl=(NL+1)*(NT/2+1)*linux_recl,&
      status='unknown')
 
      open (11,file='homedir/level_2/wk99/variable/&
      power/norm.sym.gdat',access='direct',&
         form='unformatted',recl=(NL+1)*(NT/2+1)*linux_recl,&
      status='unknown')

      open (12,file='homedir/level_2/wk99/variable/&
      power/norm.asy.gdat',access='direct',&
         form='unformatted',recl=(NL+1)*(NT/2+1)*linux_recl,&
      status='unknown')

      open (13,file='homedir/level_2/wk99/variable/&
      power/back.gdat',access='direct',&
         form='unformatted',recl=(NL+1)*(NT/2+1)*linux_recl,&
      status='unknown')
 
      read (1,rec=1) yrPEE1
      read (2,rec=1) yrPEE2
      do j=1,nt/2+1
      do i=1,nl+1
        sumPEE(i,j)=0.5*(yrPEE1(i,j)+yrPEE2(i,j))
          log_sym(i,j) = log10(yrPEE1(i,j))
          log_asy(i,j) = log10(yrPEE2(i,j))
      enddo
      enddo

! Remove the satellite aliases for olr
      if (olr) then

        do j = 1, nt/2+1
        do i = 1, nl+1
        if((ss(i).ge.13..and.ss(i).le.15.).and.&
           ff(j).gt.0.09.and.ff(j).lt.0.14) then
         sumPEE(i,j)=dmiss
        elseif((ss(i).ge.13..and.ss(i).le.15.).and.&
           ff(j).ge.0.20.and.ff(j).lt.0.23) then
         sumPEE(i,j)=dmiss
        endif
        enddo
        enddo
      endif

! smoothing
! This smoothing DOES include wavenumber zero
      do t=1, nt/2+1
       do n=1, nl+1
        mm(n)=sumPEE(n,t)
       enddo

       if (ff(t).lt.0.1) then
        do i=1,5
         call smooth121(mm,nl+1,nl+1)
        enddo
       elseif (ff(t).lt.0.2) then
        do i=1,10
         call smooth121(mm,nl+1,nl+1)
        enddo
       elseif (ff(t).lt.0.3) then
        do i=1,20
         call smooth121(mm,nl+1,nl+1)
        enddo
       else
        do i=1,40
         call smooth121(mm,nl+1,nl+1)
        enddo
       endif

       do n=1, nl+1
        sumPEE(n,t)=mm(n)
       enddo
      enddo

      do n=1, nl+1
       do t=1,NT/2-1
        frq(t)=sumPEE(n,t+1)
       enddo
       do i=1,10
        call smooth121(frq,NT/2+1,NT/2-1)
       enddo
       do t=1,NT/2-1
        sumPEE(n,t+1)=frq(t)
       enddo
      enddo


        write (13,rec=1) ((sumPEE(i,j),i=1,nl+1),j=1,nt/2+1)
 
	do i=1,nl+1
	do j=1,nt/2+1
	  if(sumPEE(i,j).ne.dmiss) then
	    log_sum(i,j)=log10(sumPEE(i,j))
	  else
	    log_sum(i,j)=dmiss
	  endif
          if (ff(j).eq.0) then
            log_sum(i,j) = dmiss
          endif

          if (log_sum(i,j).ne.dmiss) then
           norm_sym(i,j) = log_sym(i,j)-log_sum(i,j)
           norm_asy(i,j) = log_asy(i,j)-log_sum(i,j)
          else
           norm_sym(i,j) = dmiss
           norm_asy(i,j) = dmiss
          endif
	enddo
	enddo	

 
        write (11,rec=1) ((norm_sym(i,j),i=1,nl+1),j=1,nt/2+1)
        write (12,rec=1) ((norm_asy(i,j),i=1,nl+1),j=1,nt/2+1)

999	stop
	end	

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

      spv=missing
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
