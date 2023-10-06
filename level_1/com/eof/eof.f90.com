!*****************************************************************
!-----------------------------------------------------------------------
!     jst, jen, iit, nslt ::= grid selection
!     mode ::= no. of eigenmodes to be written  ( mode<30 )
!     nmo : total data,time series 
!     lx,ly: original grid number
!     mx,my: selected grid number
!     mnu : the number of non-missing data which permitted
!     mtrix: 'cov'->covariance matrix, 'cor'->correlation matrix
!     kjs: 1->xjjn=ts*ev, 2->xjjn=ts*ev*evl
!     this program is same as eofkjs.f except missing treatment
!-----------------------------------------------------------------------
      parameter (nmo1=num_t,lx=num_x,ly=num_y)
      parameter (mx=sel_x,my=sel_y,mode=10,mnu=1)
      parameter (jn=num_grid,nm=(jn*(jn+1))/2,nm2=nm*2)
      !parameter (ymax=num_r, dmax=num_d)
      integer,parameter :: ymax=num_r
      parameter (dmax=num_d)
      dimension xin2(mx,my),xin(jn),xin3(jn),udata(mx,my,nmo1)
      dimension ain2(mx,my),ain(jn),ain3(jn),adata(mx,my,nmo1)
      dimension xiin(lx,ly),xjjn(mx,my), aiin(lx,ly), ajjn(mx,my)
      dimension d(jn),wk(nm2),z(jn,jn),tmp(lx,ly)
      dimension ev(jn),t(mode),vt(jn,jn),xin1(jn), at(mode), ain1(jn)
      common /a1/sxy(nm),sm(jn),zc(jn),zz(jn),dum(mx,my)
      common /a2/dmis(mx,my),ddo(jn),ddo1(nm)
      real lat,pi
      character*150 finput,finput2
      character*3 mtrix

      integer year1, leap, linux, season
      parameter (year1 = beg_y)
      parameter (leap = leap_year, linux = linux_recl)
      parameter (season = sea_num)
      integer yy, dd, nd, skip, nod, nmo
 
      character*80 outd
      data finput &
      /'homedir/level_1/variable/data&
      /daily.5x5.filt.20-100.lanz.100.period.gdat'/ 
      data finput2 &
      /'homedir/level_1/variable/data&
      /daily.5x5.anom.period.gdat'/ 
 
      data outd &
      /'homedir/level_1/variable/eof/season/eof'/
 
      data dmiss/missing/    ! missing data
      data mtrix/'cov'/
      data kjs/1/
      open(2,file=trim(outd)//'.pct', &
           status='unknown')
      open(21,file=trim(outd)//'.pct.gdat',form='unformatted', &
           access='direct',recl=1*linux,&
           status='unknown')
      open(1,file=trim(outd)//'.ev',&
           form='unformatted',&
           status='unknown',access='direct',recl=mx*my*linux)
      open(3,file=trim(outd)//'.ts',&
           form='unformatted',&
           status='unknown',access='direct',recl=mode*linux)
      open(31,file=trim(outd)//'.ts.pr',&
           form='unformatted',&
           status='unknown',access='direct',recl=mode*linux)
! ************ data fill ************************************
      pi=3.141592
!     dd=float(nmo)
      do 440 n=1,nm
      ddo1(n)=0.
      sxy(n)=0.
440   continue
      do 441 k=1,jn
      ddo(k)=0.
      zz(k)=0.
      sm(k)=0.
441   continue
! **********************************************************
!   read data and calculate sumation 
! ************* input data reading.... *********************
      open(11,file=finput,form='unformatted',status='old',&
            access='direct',recl=lx*ly*linux)
      open(12,file=finput2,form='unformatted',status='old',&
            access='direct',recl=lx*ly*linux)

      nmo = 0

      ndd=0
      nt = 0

       yy = year1-1
       dd = 0
! print *,'ymax',ymax
      do iiy = 1, ymax

      if (leap.eq.1) then

        yy = yy + 1
        nd = dmax
        if (mod(yy,4).eq.0.and.mod(yy,100).ne.0) nd = dmax + 1
        if (mod(yy,400).eq.0) nd = dmax + 1

        if (season.eq.1) then ! winter

         skip = 304
         if (nd.eq.dmax+1) skip = 305

         nod  = 181
         if (mod(yy+1,4).eq.0.and.mod(yy,100).ne.0) nod = 182
         if (mod(yy+1,400).eq.0) nod = 182

        elseif (season.eq.2) then ! summer

         skip = 120
         if (nd.eq.dmax+1) skip = 121
         nod  = 184

        endif
   
      else if (leap.eq.0) then

      if (dmax.eq.360) then
        if (season.eq.1) then ! winter
         skip = 300
         nod  = 180
        elseif (season.eq.2) then ! summer
         skip = 120
         nod  = 180
        endif
      else
        if (season.eq.1) then ! winter
         skip = 304
         nod  = 181
        elseif (season.eq.2) then ! summer
         skip = 120
         nod  = 184
        endif
      endif

      endif

      do id = 1, nod

       nt = nt + 1

      if (leap.eq.1) then
       ii= dd+skip+id
      else if (leap.eq.2) then
       ii= dmax*(iiy-1)+skip+id
      endif

         nmo = nmo + 1
         read(11,rec=ii) xiin
         read(12,rec=ii) aiin

         iy=0
         do j=1,my
            lat=beg_lat+(j-1.)*5. !  latitude weighting
            iy=iy+1
            ix=0
         do i=1,mx
            ix=ix+1
            xjjn(ix,iy)=xiin(i,j+num_jump)   !data selection
            ajjn(ix,iy)=aiin(i,j+num_jump)   !data selection
            if (xjjn(ix,iy).ne.dmiss) then
               udata(ix,iy,nt)=xjjn(ix,iy)*cos(lat*pi/180.)
            else 
               udata(ix,iy,nt)=dmiss
            endif
            if (ajjn(ix,iy).ne.dmiss) then
               adata(ix,iy,nt)=ajjn(ix,iy)*cos(lat*pi/180.)
            else 
               adata(ix,iy,nt)=dmiss
            endif
         enddo
         enddo

      enddo ! id

       if (leap.eq.1) dd = dd + nd

      enddo ! iy

!************************************************************       
       print *,'nmo=',nmo,season
       call miss(udata,mx,my,nmo,dmis,dmiss)
!***********************************************************
        do 43 kk=1,nmo
            k=0 
          do 25 j=1,my
          do 25 i=1,mx
            if (dmis(i,j).ge.mnu) go to 25 
            k=k+1
            xin(k)=udata(i,j,kk)
            ain(k)=adata(i,j,kk)
            if(xin(k) .eq. dmiss) go to 25
            sm(k)=sm(k)+xin(k)     !summation
            ddo(k)=ddo(k)+1.
25        continue
43      continue
        if (k .ne. jn) then
        print *,'error','jn=',k
        stop
        endif	
!****************************************************************
!                        calculate sxy
!****************************************************************
      do 109 imo2 = 1, nmo
      k=0
      do 112 j=1,my
      do 112 i=1,mx
         if (dmis(i,j).ge.mnu) go to 112
            k = k+1
            zc(k) =udata(i,j,imo2)-sm(k)/ddo(k)  !anomaly
         if (udata(i,j,imo2).eq.dmiss) then
            zc(k)=dmiss
            go to 112
         endif
         zz(k)=zz(k)+zc(k)**2
112   continue
      n=0 
      do 500 j=1,jn  
      do 500 i=1,j                                          
         n=n+1  
      if(zc(i).eq.dmiss .or. zc(j).eq.dmiss) go to 500
      sxy(n)=sxy(n)+zc(i)*zc(j)
      ddo1(n)=ddo1(n)+1.
500   continue                                                          
109   continue
!*****************************************************************
      do 77 kk=1,jn
         zz(kk)=sqrt(zz(kk)/ddo(kk))  !standard deviation
         if (zz(kk) .eq. 0) print*,'error zz(k)',zz(kk),kk
77    continue
      print *,'ok2'
      n=0
      do 700 j=1,jn
      do 700 i=1,j
      n=n+1
      if(ddo1(n).eq.0) print*,n,ddo1(n)
      if (mtrix .eq. 'cov') sxy(n)=sxy(n)/ddo1(n)       !covariance
      if (mtrix .eq. 'cor') sxy(n)=sxy(n)/(zz(i)*zz(j)) !correlation
700   continue                                                          
      print*, 'ok3'
!********************************************************
!     dd=float(nmo)
      nl=jn
      print*,'eigenfunction calculation started'
!**********************************************************
      call symtrx(sxy,nl,d,z,nl,wk,ier)
!*********************************************************
      print*,'eigenfuntions computed'
      se=0.                                                             
      do 10 k=1,nl                                                      
  10  se=se+d(k)                                                        
      do 15 k=1,nl                                                      
      kk=nl-k+1                                                         
      ev(k)=d(kk)*100./se                                               
  15  continue                                                          
  16  format(//////,20x,'percentage variance of eigenvector',/)            
!17   format(5x,5f12.2,////)                                            
 17   format(10f12.2)                                            
!     write(2,16)                                                       
      write(2,17) (ev(i),i=1,mode)  !eigen value (pct)                         
      write(2,17) (ev(i),i=1,mode)  !eigen value (pct)                         
      write(2,17) (ev(i),i=1,mode)  !eigen value (pct)                         
      do i = 1, mode
       write (21,rec=i) ev(i)
      enddo
!***************************************************************
!  write leading eigenvectors.
!***************************************************************
      do 150 i=1,nl
      do 140 k=1,mode
      kk=nl-k+1
  140 vt(i,k)=z(i,kk)
  150 continue
       do 160 k=1,mode
	nn=0
	do 165 j=1,my
	do 165 i=1,mx
        dum(i,j)=dmiss
        if(dmis(i,j).ge.mnu) go to 165
	nn=nn+1
	dum(i,j)=vt(nn,k)
165    continue
       write(1,rec=k) dum
160    continue
!***********************************************
!  calculate and write the time series.
!*************************************************
      do 129 imo2 = 1,nmo
      k=0
      do 113 j=1,my
      do 113 i=1,mx
       if(dmis(i,j).ge.mnu) go to 113
       k = k+1
       xin1(k) = udata(i,j,imo2)
       ain1(k) = adata(i,j,imo2)
       if (xin1(k) .eq. dmiss) then
          print*,'miss error',i,j,kk,xin1(k)
          stop
       endif
113    continue
      do 50 i=1,nl
      zc(i)=xin1(i)-sm(i)/ddo(i)
      if(xin1(i).eq.dmiss) zc(i)=dmiss
!     zc(i)=zc(i)/zz(i)
50    continue
      do 300 k=1,mode
      ts=0.                                                            
      ats=0.                                                            
      do 250 i=1,nl                                                     
      if(zc(i).eq.dmiss) go to 250
      ts=ts+zc(i)*vt(i,k)                                             
! pc when projected to raw data (not filtered)
      ats=ats+ain1(i)*vt(i,k)                                             
  250 continue                                                          
      if (kjs .eq. 1) t(k)=ts       !xjjn(i,j,k)=ev(i,j)*ts(k)
      if (kjs .eq. 2) t(k)=ts/ev(k) !xjjn(i,j,k)=ev(i,j)*ts(k)*ev(k)

      if (kjs .eq. 1) at(k)=ats     
  300 continue
      write(3,rec=imo2) (t(l),l=1,mode)
      write(31,rec=imo2) (at(l),l=1,mode)
 129  continue
      stop  
      end                                                               
!c*********************************************************
      subroutine symtrx(rowij,m,root,eigv,ni,wk,ier)
!$name  symtrx
!$link  cpcon
! solves eigenfunction problem for symmetric matrix
!--- history
! 89.12. 4 modified with cncpu
! 90. 1. 6 cncpu is replaced by prec.
!--- input
! m       i      order of original symmetric matrix
! ni      i      initial dimension of -root-, -eigv- and -wk-
! rowij  r(*)    symmetric storage mode of order m*(m+1)/2
!--- output
! eigv   r(ni,m) eigenvectors of original symmetric matrix
! ier     i      index for root(j) failed to converge (j=ier-128)
! root   r(m)    eigenvalues of original symmetric matrix
! rowij          storage of householder reduction elements
! wk             work area
!$endi
      real rowij(*),root(*),wk(*),eigv(ni,*),ccp(3)
!+++ add epscp
!     data  rdelp/ 1.1921e-07 /
      call cpcon(ccp)
      rdelp=ccp(1)*10
      ier = 0
      mp1 = m + 1
      mm = (m*mp1)/2 - 1
      mbeg = mm + 1- m
!+---------------------------------------------------------------------+
!|          loop-100 reduce -rowij- (symmetric storage mode) to a      |
!|          symmetric tridiagonal form by householder method           |
!|                      cf. wilkinson, j.h., 1968,                     |
!|              the algebraic eigenvalue problem, pp 290-293.          |
!|          loop-30&40 and 50 form element of a*u and element p        |
!+---------------------------------------------------------------------+
      do 100 ii=1,m
      i = mp1 - ii
      l = i - 1
      h = 0.0
      scale = 0.0
      if (l.lt.1) then
!|          scale row (algol tol then not needed)
      wk(i) = 0.0
      go to 90
      end if
      mk = mm
      do 10 k=1,l
      scale = scale + abs(rowij(mk))
      mk = mk - 1
   10 continue
      if (scale.eq.0.0) then
      wk(i) = 0.0
      go to 90
      end if
!**********************************************c
      mk = mm
      do 20 k = 1,l
      rowij(mk) = rowij(mk)/scale
      h = h + rowij(mk)*rowij(mk)
      mk = mk - 1
   20 continue
      wk(i) = scale*scale*h
      f = rowij(mm)
      g = - sign(sqrt(h),f)
      wk(i) = scale*g
      h = h - f*g
      rowij(mm) = f - g
      if (l.gt.1) then
      f = 0.0
      jk1 = 1
      do 50 j=1,l
      g = 0.0
      ik = mbeg + 1
      jk = jk1
      do 30 k=1,j
      g = g + rowij(jk)*rowij(ik)
      jk = jk + 1
      ik = ik + 1
   30 continue
      jp1 = j + 1
      if (l.ge.jp1) then
      jk = jk + j - 1
      do 40 k=jp1,l
      g = g + rowij(jk)*rowij(ik)
      jk = jk + k
      ik = ik + 1
   40 continue
      end if
      wk(j) = g/h
      f = f + wk(j)*rowij(mbeg+j)
      jk1 = jk1 + j
   50 continue
      hh = f/(h+h)
!*****************************************************
      jk = 1
      do 70 j=1,l
      f = rowij(mbeg+j)
      g = wk(j) - hh*f
      wk(j) = g
      do 60 k=1,j
      rowij(jk) = rowij(jk) - f*wk(k) - g*rowij(mbeg+k)
      jk = jk + 1
   60 continue
   70 continue
      end if

      do 80 k=1,l
      rowij(mbeg+k) = scale*rowij(mbeg+k)
   80 continue
   90 root(i) = rowij(mbeg+i)
      rowij(mbeg+i) = h*scale*scale
      mbeg = mbeg - i + 1
      mm = mm - i
  100 continue
!+---------------------------------------------------------------------+
!|          loop-210 compute eigenvalues and eigenvectors              |
!|          setup work area location eigv to the identity matrix       |
!|          loop-140 for finding small sub-diagonal element            |
!|          loop-160 for convergence of eigenvalue j (max. 30 times)   |
!|          loop-190 for ql transformation and loop-180 form vectors   |
!+---------------------------------------------------------------------+
      do 110 i=1,m-1
  110 wk(i) = wk(i+1)
      wk(m) = 0.0
      b = 0.0
      f = 0.0
      do 130 i=1,m
      do 120 j=1,m
  120 eigv(i,j) = 0.0
      eigv(i,i) = 1.0
  130 continue

      do 210 l=1,m
      j = 0
      h = rdelp*(abs(root(l))+abs(wk(l)))
      if (b.lt.h) b = h
      do 140 n=l,m
      k = n
      if (abs(wk(k)).le.b) go to 150
  140 continue
  150 n = k
      if (n.eq.l) go to 200

  160 continue
      if (j.eq.30) then
      ier = 128 + l
      return
      end if

      j = j + 1
      l1 = l + 1
      g = root(l)
      p = (root(l1)-g)/(wk(l)+wk(l))
      r = abs(p)
      if (rdelp*abs(p).lt.1.0) r = sqrt(p*p+1.0)
      root(l) = wk(l)/(p+sign(r,p))
      h = g - root(l)
      do 170 i=l1,m
      root(i) = root(i) - h
  170 continue
      f = f + h

      p = root(n)
      c = 1.0
      s = 0.0
      nn1 = n - 1
      nn1pl = nn1 + l
      if (l.le.nn1) then
      do 190 ii=l,nn1
      i = nn1pl - ii
      g = c*wk(i)
      h = c*p
      if (abs(p).lt.abs(wk(i))) then
      c = p/wk(i)
      r = sqrt(c*c+1.0)
      wk(i+1) = s*wk(i)*r
      s = 1.0/r
      c = c*s
      else
      c = wk(i)/p
      r = sqrt(c*c+1.0)
      wk(i+1) = s*p*r
      s = c/r
      c = 1.0/r
      end if
      p = c*root(i) - s*g
      root(i+1) = h + s*(c*g+s*root(i))
      if (ni.ge.m) then
      do 180 k=1,m
      h = eigv(k,i+1)
      eigv(k,i+1) = s*eigv(k,i) + c*h
      eigv(k,i) = c*eigv(k,i) - s*h
  180 continue
      end if
  190 continue
      end if
      wk(l) = s*p
      root(l) = c*p
      if (abs(wk(l)).gt.b) go to 160
  200 root(l) = root(l) + f
  210 continue
!+---------------------------------------------------------------------+
!|          back transform eigenvectors of the original matrix from    |
!|          eigenvectors 1 to m of the symmetric tridiagonal matrix    |
!+---------------------------------------------------------------------+
      do 250 i=2,m
      l = i - 1
      ia = (i*l)/2
      if (rowij(ia+i).ne.0.0) then
      do 240 j=1,m
      sum = 0.0
      do 220 k=1,l
      sum = sum + rowij(ia+k)*eigv(k,j)
  220 continue
      sum = sum/rowij(ia+i)
      do 230 k=1,l
      eigv(k,j) = eigv(k,j) - sum*rowij(ia+k)
  230 continue
  240 continue
      end if
  250 continue
      return
      end
!c************************************************************
      subroutine cpcon(c)
!$name  cpcon
! machine constants of computer
!--- output
! c     r(3)      (1)  minimum positive x for  1+x      .ne. 1
!                 (2)  minimum exponent y for  10.0**y  .ne. 0
!                 (3)  maximum exponent z for  10.0**z  is max. value
!                  if init=1 (data statement) then  set as z=y
!                  if init=2 then this routine gets actual value of z.
!                  - see note -
!--- history
! 90. 1.20  created
!
!--- note
! this program will generate -underflow error- and -overflow error-
!  messages.  on some computer -overflow error- message may be
!  fatal error.  in that case, please set init = 1 in the data
!  satement for suppressing the procedure of getting c(3).
      dimension c(3)
! resolution of computation
      save init,x,y,z
      data init/1/
      if(init.le.0) then
	c(1)=x
	c(2)=y
	c(3)=z
	return
      endif
      n=500
      x=1
      do 1 i=1,n
      x=x/2
      x1=1+x
      if(abs(x1-1) .le. 0) then
	x=2*x
	goto 2
      endif
    1 continue
    2 c(1)=x
! exponent for minimum positive value
!  this procedure will generate -underflow error massage-
      y2=1
      n=500
      do 3 i=1,n
      y1=y2
      y2=y1/10
      if(abs(10*y2/y1-1) .gt. 20*x) goto 4
    3 continue
      i=n+1
    4 y=1-i
      c(2)=y
! exponent for maximum positive value
! this procedure will generate -overflow message-
      if(init.le.1) then
	z=-y
       else
	z2=1
	n=500
	do 5 i=1,n
	z1=z2
	z2=z1*10
	if(abs(z2/z1/10-1) .gt. 20*x) goto 6
    5   continue
	i=n+1
    6   z=i-1
      endif
      c(3)=z

      init=0
      return
      end
!***********************************************************
      subroutine miss(udata,mx,my,nt,dmis,dmiss)
!**** Counting data-missing for point & Time******
!**** data(lx,ly) : number of missing data for each point***
!**** data2(lx,ly) : input data **********
      dimension dmis(mx,my),udata(mx,my,nt)
      print *,'start miss subroutine'
      do 190 jj=1,my
      do 190 ii=1,mx
         dmis(ii,jj)=0.
  190 continue
      do 90 jj=1,my
      do 90 ii=1,mx
         nn=0
         do 84 k=1,nt
            if (udata(ii,jj,k).eq.dmiss) then
               dmis(ii,jj)=dmis(ii,jj)+1.
            endif
            if (udata(ii,jj,k).eq.0) then
               nn=nn+1
            endif
   84    continue
         if (nn.eq.nt) dmis(ii,jj)=nt ! all zero grid remove
   90 continue
      kkk=0
      do j=1,my
      do i=1,mx
         if (dmis(i,j) .eq. 0.) then
            kkk=kkk+1
         endif
      enddo
      enddo
      print *,kkk
      print*,'miss subroutine end'
      return
      enD
